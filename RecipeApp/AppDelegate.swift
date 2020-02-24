//
//  AppDelegate.swift
//  RecipeApp
//
//  Created by Lam Pham on 2/22/20.
//  Copyright © 2020 Lam Pham. All rights reserved.
//

import UIKit
import CoreData
import XMLMapper
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var coreDataStack = CoreDataStack(modelName: "RecipeApp")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        importXMLDataIfNeeded()
        
        UITabBar.appearance().tintColor = .systemYellow
        
        UINavigationBar.appearance().barStyle = .default
        IQKeyboardManager.shared.enable = true
        
        let vc = RecipesListViewController.instantiateFromNib()
        vc.coreDataStack = coreDataStack
        let nav = UINavigationController(rootViewController: vc)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RecipeApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


extension AppDelegate {
    func importXMLDataIfNeeded() {
        
        let fetchRequest: NSFetchRequest<RecipeItem> = RecipeItem.fetchRequest()
        let count = try? coreDataStack.managedContext.count(for: fetchRequest)
        
        guard let itemCount = count, itemCount == 0 else {
            return
        }
        
        loadDataFromXMLFile()
    }
    
    func loadDataFromXMLFile(code: String = "recipetypes") {
        var dataString: String?
        
        let xmlURL = Bundle.main.url(forResource: code, withExtension: "xml")!
        let jsonData = NSData(contentsOf: xmlURL)! as Data
        
        dataString = String(decoding: jsonData, as: UTF8.self)
        
        let modelFromLocal = ListDataModel(XMLString: dataString!.replacingOccurrences(of: "&", with: "&amp;", options: .literal, range: nil))
        
        let igradientEntity = NSEntityDescription.entity(forEntityName: "IngredientItem", in: coreDataStack.managedContext)!
        let stepEntity = NSEntityDescription.entity(forEntityName: "StepItem", in: coreDataStack.managedContext)!
        let recipeEntity = NSEntityDescription.entity(forEntityName: "RecipeItem", in: coreDataStack.managedContext)!
        
        modelFromLocal?.dataList.forEach({ (element) in
            
            let recipe = RecipeItem(entity: recipeEntity, insertInto: coreDataStack.managedContext)
            
            element.ingredients?.forEach({ (eleIngredient) in
                let ingredient = IngredientItem(entity: igradientEntity, insertInto: coreDataStack.managedContext)
                ingredient.materialName = eleIngredient.materialName
                ingredient.quantity = eleIngredient.quantity
                ingredient.descriptionNote = eleIngredient.descriptionNote
                
                recipe.addToIngredients(ingredient)
            })
            
            element.steps?.forEach({ (eleStep) in
                let step = StepItem(entity: stepEntity, insertInto: coreDataStack.managedContext)
                step.stepName = eleStep.stepName
                step.stepOrder = eleStep.stepOrder
                step.descriptionNote = eleStep.descriptionNote
                
                recipe.addToStepsRecipe(step)
            })
            
            recipe.name = element.name
            recipe.type = element.type
            recipe.dateCreated = element.dateCreated
            
        })
        
        if coreDataStack.managedContext.hasChanges {
            coreDataStack.saveContext()
        }
    }

}
