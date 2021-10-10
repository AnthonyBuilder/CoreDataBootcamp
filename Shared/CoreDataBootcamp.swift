//
//  CoreDataBootcamp.swift
//  CoreDataBootcamp
//
//  Created by Anthony José on 05/10/21.
//

import SwiftUI
import CoreData

// View - UI
// Model - data point
// ViewModel - manages the data for a view

class CoreDataViewModel: ObservableObject {
    
    let container: NSPersistentContainer // define data model
    @Published var savedEntities: [FruitEntity] = [] // return saved items on data model
    
    init() {
        container = NSPersistentContainer(name: "FruitsContainer")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("ERROR LOADING CORE DATA. \(error)")
            }
        }
        
        fetchFruits()
    }
    
    // MARK: - get fruits on data model
    func fetchFruits() {
        let request = NSFetchRequest<FruitEntity>(entityName: "FruitEntity")
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error as NSError {
            print("Error for fetching. \(error), code: \(error.code)")
        }
    }
    
    //MARK: -  place new fruit on data
    func addFruit(text: String) {
        let newFruit = FruitEntity(context: container.viewContext)
        newFruit.name = text
        saveData()
    }
    
    func update(entity: FruitEntity, newValue: String) {
        entity.name = newValue
        saveData()
    }
    
    // MARK: - try save modified on context
    func saveData() {
        do {
           try container.viewContext.save()
            fetchFruits()
        } catch let error {
            print("Failed save data. \(error)")
        }
    }
    
    func deleteFruit(indexSet: IndexSet) {
        guard let index = indexSet.first else { return } // get first element selected on index
        let entity = savedEntities[index]
        container.viewContext.delete(entity)
        saveData()
    }
}

struct CoreDataBootcamp: View {
    
    @StateObject var vm = CoreDataViewModel()
    @State var textFieldValue: String = ""
    @State var textFieldValueForUpdate: String = ""
    @State var textFieldTransform: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Adicione uma fruta aqui...", text: $textFieldValue)
                    .font(.headline)
                    .padding(.leading)
                    .frame(height: 55)
                    .background(Color(.init(gray: 0.5, alpha: 0.5)))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    guard !textFieldValue.isEmpty else { return }
                    vm.addFruit(text: textFieldValue)
                    textFieldValue = ""
                }) {
                    Text("Salvar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(10)
                }.padding(.horizontal)
                
                List {
                    ForEach(vm.savedEntities) { entity in
                        if textFieldTransform == true {
                            if #available(iOS 15.0, *) {
                                TextField(entity.name ?? "NO NAME", text: $textFieldValueForUpdate)
                                    .onSubmit {
                                        vm.update(entity: entity, newValue: textFieldValueForUpdate)
                                        textFieldTransform = false
                                    }
                            } else {
                                // Fallback on earlier versions
                            }
                        } else {
                            Text(entity.name ?? "NO NAME")
                            .onTapGesture {
                                textFieldTransform.toggle()
                            }
                        }
                    }.onDelete(perform: vm.deleteFruit)
                }
            }.navigationTitle("Frutas ")
        }
    }
}

struct CoreDataBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataBootcamp()
    }
}
