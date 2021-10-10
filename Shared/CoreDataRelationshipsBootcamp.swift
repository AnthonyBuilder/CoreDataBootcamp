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
    
    init() {
        getBusiness()
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
        // newBusiness.addToDepartments(<#T##value: DepartmentEntity##DepartmentEntity#>)
        
        // add new business to existing employees
        // newBusiness.addToEmployees(<#T##value: EmployeeEntity##EmployeeEntity#>)
        
        save()
    }
    
    func addDepartment() {
        let newDepartment = DepartmentEntity(context: manager.context)
        newDepartment.name = "Marketing"
        newDepartment.businesses = [businesses[0]]
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
    
    func save() {
        businesses.removeAll()
        departments.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.manager.save()
            self.getBusiness()
            self.getDepartments()
        }
    }
}

struct CoreDataRelationshipsBootcamp: View {
    
    @StateObject var vm = CoreDataRelationshipsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Button(action: {
                        vm.addDepartment()
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
                                }
                            }.padding()
                        }
                    }
                }
            }.navigationTitle("Relationships")
        }
    }
}

struct BusinessView: View {
    let entity: BusinessEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Name: \(entity.name ?? "")")
                    .bold()
            
            if let departments = entity.departments?.allObjects as? [DepartmentEntity] {
                Text("Departments:")
                    .bold()
                ForEach(departments) { department in
                    Text(department.name ?? "")
                }
            }
            
            if let employess = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Employees:")
                    .bold()
                ForEach(employess) { employee in
                    Text(employee.name ?? "")
                }
            }
        }.padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.gray.opacity(0.4))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct DepartmentView: View {
    let entity: DepartmentEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Name: \(entity.name ?? "")")
                    .bold()
            
            if let businesses = entity.businesses?.allObjects as? [BusinessEntity] {
                Text("Businesses:")
                    .bold()
                ForEach(businesses) { business in
                    Text(business.name ?? "")
                }
            }
            
            if let employess = entity.employess?.allObjects as? [EmployeeEntity] {
                Text("Employees:")
                    .bold()
                ForEach(employess) { employee in
                    Text(employee.name ?? "")
                }
            }
        }.padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.green.opacity(0.4))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct CoreDataRelationshipsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataRelationshipsBootcamp()
    }
}
