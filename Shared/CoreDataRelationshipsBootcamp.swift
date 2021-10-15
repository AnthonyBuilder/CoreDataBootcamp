//
//  CoreDataRelationshipsBootcamp.swift
//  CoreDataBootcamp
//
//  Created by Anthony José on 08/10/21.
//

import SwiftUI
import CoreData

// 3 Entityes
// BusinessEntity
// DepartamentEntity
// EmployeeEntity

class CoreDataManager {
    static let instance = CoreDataManager()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "CoreDataContainer")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading Core Data. \(error)")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
            print("Saved successfully!")
        } catch let error {
            print("Error saving Core Data. \(error.localizedDescription)")
        }
    }
}

class CoreDataRelationshipsViewModel: ObservableObject {
    
    let manager = CoreDataManager.instance
    @Published var businesses: [BusinessEntity] = []
    @Published var departments: [DepartmentEntity] = []
    @Published var employees: [EmployeeEntity] = []

    init() {
        getBusiness()
        getDepartments()
        getEmployees()
    }
    
    func getBusiness() {
        let request = NSFetchRequest<BusinessEntity>(entityName: "BusinessEntity")
        
        do {
            try businesses = manager.context.fetch(request)
        } catch let error {
            print("Error fetching data. \(error.localizedDescription)")
        }
    }
    
    func addBusiness() {
        let newBusiness = BusinessEntity(context: manager.context)
        newBusiness.name = "Apple"
        
        // add existing departments to the new business
        // newBusines.departments = []
        
        // add existing employess to the new busines
        // newBusiness.employees = []
        
        // add new business to existing departments
        newBusiness.addToDepartments(departments[0])
        
        // add new business to existing employees
        newBusiness.addToEmployees(employees[0])
        
        save()
    }
    
    func updateBusiness() {
        let existingBusiness = businesses[2]
        existingBusiness.addToDepartments(departments[1])
        save()
    }
    
    func addDepartment() {
        let newDepartment = DepartmentEntity(context: manager.context)
        newDepartment.name = "Marketing"
        //newDepartment.businesses = [businesses[0]]
        
        newDepartment.addToEmployess(employees[0])
        save()
    }
    
    func getDepartments() {
        let request = NSFetchRequest<DepartmentEntity>(entityName: "DepartmentEntity")
        
        do {
            try departments = manager.context.fetch(request)
        } catch let error {
            print("Error fetching data. \(error.localizedDescription)")
        }
    }
    
    func addEmployee() {
        let newEmployee = EmployeeEntity(context: manager.context)
        newEmployee.age = 99
        newEmployee.dateJoined = Date()
        newEmployee.name = "Emily"
        
//        newEmployee.business = businesses[0]
//        newEmployee.department = departments[0]
        save()
    }
    
    func getEmployees() {
        let request = NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
        
        do {
            try employees = manager.context.fetch(request)
        } catch let error {
            print("Error fetching data. \(error.localizedDescription)")
        }
    }
    
    func removeBusiness(indexSet: BusinessEntity) {
        manager.container.viewContext.delete(indexSet)
        save()
    }
    
    func removeDepartment(indexSet: DepartmentEntity) {
        manager.container.viewContext.delete(indexSet)
        save()
    }
    
    func removeEmployee(indexSet: EmployeeEntity) {
        manager.container.viewContext.delete(indexSet)
        save()
    }
    
    func save() {
        businesses.removeAll()
        departments.removeAll()
        employees.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.manager.save()
            self.getBusiness()
            self.getDepartments()
            self.getEmployees()
        }
    }
}


// MARK: CoreDataRelationshipsBootcamp - View

struct CoreDataRelationshipsBootcamp: View {
    
    @StateObject var vm = CoreDataRelationshipsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Button(action: {
                        vm.addBusiness()
                    }) {
                        Text("Perform Action")
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.cornerRadius(10))
                    }.padding()
                    
                    VStack(alignment: .leading) {
                        Text("Empresa")
                            .bold()
                            .font(.headline)
                            .padding(.leading)
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(alignment: .top) {
                                ForEach(vm.businesses) { business in
                                    BusinessView(entity: business)
                                        .onTapGesture {
                                            vm.removeBusiness(indexSet: business)
                                        }
                                }
                            }.padding()
                        }
                        
                        Text("Departamento")
                            .bold()
                            .font(.headline)
                            .padding(.leading)
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(alignment: .top) {
                                ForEach(vm.departments) { department in
                                    DepartmentView(entity: department)
                                        .onTapGesture {
                                            vm.removeDepartment(indexSet: department)
                                        }
                                }
                            }.padding()
                        }
                        
                        Text("Funcionario")
                            .bold()
                            .font(.headline)
                            .padding(.leading)
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(alignment: .top) {
                                ForEach(vm.employees) { employee in
                                    EmployeeView(entity: employee)
                                        .onTapGesture {
                                            vm.removeEmployee(indexSet: employee)
                                        }
                                }
                            }.padding()
                        }
                    }
                }
            }.navigationTitle("Relationships")
        }
    }
}

// MARK: Business - View

struct BusinessView: View {
    let entity: BusinessEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Nome: \(entity.name ?? "")")
                    .bold()
            
            if let departments = entity.departments?.allObjects as? [DepartmentEntity] {
                Text("Departamento:")
                    .bold()
                ForEach(departments) { department in
                    Text(department.name ?? "")
                }
            }
            
            if let employess = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Funcionario:")
                    .bold()
                ForEach(employess) { employee in
                    Text(employee.name ?? "")
                }
            }
        }.padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.gray)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

// MARK: Department - View

struct DepartmentView: View {
    let entity: DepartmentEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Nome: \(entity.name ?? "")")
                    .bold()
            
            if let businesses = entity.businesses?.allObjects as? [BusinessEntity] {
                Text("Empresa:")
                    .bold()
                ForEach(businesses) { business in
                    Text(business.name ?? "")
                }
            }
            
            if let employess = entity.employess?.allObjects as? [EmployeeEntity] {
                Text("Funcionario:")
                    .bold()
                ForEach(employess) { employee in
                    Text(employee.name ?? "")
                }
            }
        }.padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.green)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

// MARK: Employee - View

struct EmployeeView: View {
    let entity: EmployeeEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Name: \(entity.name ?? "")")
                    .bold()
            
            Text("Idade: \(entity.age)")
            Text("Data que ingresou: \(entity.dateJoined ?? Date())")
            
            Text("Empresa:")
                .bold()
            Text(entity.business?.name ?? "")
            
            Text("Departamento:")
                .bold()
            Text(entity.department?.name ?? "")
        }.padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.blue)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}


// MARK: Preview

struct CoreDataRelationshipsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataRelationshipsBootcamp()
    }
}
