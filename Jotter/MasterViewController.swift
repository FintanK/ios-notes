//
//  MasterViewController.swift
//  Jotter
//
//  Created by Fintan Kearney on 2016-04-20.
//  Copyright © 2016 fintankearney. All rights reserved.
//

import UIKit

var objects:[String] = [String]()
var currentIndex:Int = 0
var masterView:MasterViewController?
var detailViewController:DetailViewController?

// Key for data in persistent storage
let kNotes:String = "notes"
let BLANK_NOTE:String = "(New Note)"



class MasterViewController: UITableViewController {

    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        masterView = self
        load()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
        // Persist our data
        save()
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if objects.count == 0 {
            insertNewObject(self)
        }
        
        super.viewDidAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Create a new note
    func insertNewObject(sender: AnyObject) {
        
        // Only create a new note outside of editing mode
        if detailViewController?.detailDescriptionLabel.editable == false {
            return
        }
        
        // Prevent multiple blank notes
        if objects.count == 0 || objects[0] != BLANK_NOTE {
            objects.insert(BLANK_NOTE, atIndex: 0)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        currentIndex = 0
        
        // Show detail view
        self.performSegueWithIdentifier("showDetail", sender: self)
        
        
    }

    // Prepare for transition from master view to detail view (notes view to note view)
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        detailViewController?.detailDescriptionLabel.editable = true

        
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                currentIndex = indexPath.row
            }
            
            let object = objects[currentIndex]
            detailViewController?.detailItem = object
            detailViewController?.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            detailViewController?.navigationItem.leftItemsSupplementBackButton = true
            
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Handling deletes
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // Don't save deletions if editing deletions - only delete when done

    override func setEditing(editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        if editing {
            detailViewController?.detailDescriptionLabel.editable = false
            detailViewController?.detailDescriptionLabel.text = ""
            return
        }
        
        save()
    }
    
    // wWhen an item is deleted when swiping to the left
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        detailViewController?.detailDescriptionLabel.editable = false
        detailViewController?.detailDescriptionLabel.text = ""
        save()
    }
    

    
    // Saving and loading from device memory / disk
    
    func save() {
        
        NSUserDefaults.standardUserDefaults().setObject(objects, forKey: kNotes);
        
        // Persist to disk straight away in case the app crashes
        NSUserDefaults.standardUserDefaults().synchronize();
        
    }
    
    func load() {
        // Idf data exists
        if let loadedData = NSUserDefaults.standardUserDefaults().arrayForKey(kNotes) as? [String] {
            objects = loadedData
        }
    }


}

