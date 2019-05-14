//
//  MainViewController.swift
//  fluid
//
//  Created by Ziyad Khalil on 5/6/19.
//  Copyright © 2019 Ziyad Khalil. All rights reserved.
//

import UIKit
import CoreData
import JTAppleCalendar


class MainViewController: UIViewController {
    
    //-MARK:- Attributes
    
    var navBarController: NavBarController!     //NavigationController Reference
    var dateText: String!
    var tasksData: [Entity] = []
    var doneTasks: [Entity] = []
    var undoneTasks: [Entity] = []
    var eventsData: [Entity] = []
    var notesData: [Entity] = []
    var gradient: CAGradientLayer!
    @IBOutlet weak var eventsTable: UITableView!
    @IBOutlet weak var calendar: JTAppleCalendarView!
    @IBOutlet weak var calendarView: UIView!
    
    //IB outlets
    @IBOutlet weak var tasksTable: UITableView!
    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var calenderMonthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    
    //MARK:- Functions
    @IBAction func dateLabelTapped(_ sender: Any) {
        calendar.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.dateLabel.isHidden = true
            self.calendarView.isHidden = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.deselectAllDates()
        calendar.allowsMultipleSelection = false
        calendar.scrollToDate(navBarController.currentDate)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navBarController.setNavigationBarHidden(true, animated: true)
        refresh()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navBarController.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let targetVC = segue.destination as! DetailsViewController;
        let segueIdentifier = segue.identifier!
        targetVC.navBarController = navBarController
        

        switch(segueIdentifier){
        case "EventsDetails":
            targetVC.title! = "Events"
            targetVC.data = eventsData
            targetVC.currentMode = .event
            navBarController.navigationBar.tintColor = UIColor(named: "trkwaz")
            navBarController.navigationBar.titleTextAttributes![NSAttributedString.Key.foregroundColor] = UIColor(named: "trkwaz")

            break
        case "NotesDetails":
            targetVC.title! = "Notes"
            targetVC.data = notesData
            targetVC.currentMode = .note
            navBarController.navigationBar.tintColor = UIColor.white
            navBarController.navigationBar.titleTextAttributes![NSAttributedString.Key.foregroundColor] = UIColor.white


            break
        case "TasksDetails":
            targetVC.title = "Tasks"
            targetVC.data = tasksData
            targetVC.currentMode = .task
            navBarController.navigationBar.tintColor = UIColor(named: "LamonyKamony")
            navBarController.navigationBar.titleTextAttributes![NSAttributedString.Key.foregroundColor] = UIColor(named: "LamonyKamony")
            

            break
        
        default:
            break
        }
        
    }
    
    func reloadTables(){
        tasksTable.reloadData()
        notesTable.reloadData()
        eventsTable.reloadData()
    }
    
    func refresh(){
        dateLabel.text? = dateText
        tasksData = navBarController.currentTasks
        doneTasks = []
        undoneTasks = []
        tasksData.forEach{ task in
            if task.isTaskDone {doneTasks.append(task)}
            else {undoneTasks.append(task)}
        }
        eventsData = navBarController.currentEvents
        notesData = navBarController.currentNotes
        reloadTables()
    }
    

    }

//--MARK: TABLE DELEGATE AND DATA SOURCE EXTENSION
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (tableView) {
        case tasksTable:
            return (section == 0 ? self.undoneTasks.count : self.doneTasks.count)
        case notesTable:
            return notesData.count
        case eventsTable:
            return eventsData.count
        default:
            return -1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MainViewCell!
        switch(tableView){
        case tasksTable:
            if indexPath.section == 0 {
                cell = (tableView.dequeueReusableCell(withIdentifier: "UnfinishedBusiness") as! MainViewCell)
                cell.label.text = undoneTasks[indexPath.row].value!
                cell.label.sizeToFit()
                tableView.rowHeight = cell.label.frame.height + 6
            }
            else {
                cell = (tableView.dequeueReusableCell(withIdentifier: "FinishedBusiness") as! MainViewCell)
                cell.label.attributedText = doneTasks[indexPath.row].value!.strikeThrough()
                cell.label.sizeToFit()
                tableView.rowHeight = cell.label.frame.height + 6
            }
            break
        case notesTable:
            cell = (tableView.dequeueReusableCell(withIdentifier: "Note") as! MainViewCell)
            cell.label.text = notesData[indexPath.row].value!
            cell.label.sizeToFit()
            tableView.rowHeight = cell.label.frame.height + 6
            break
        case eventsTable:
            cell = (tableView.dequeueReusableCell(withIdentifier: "Event") as! MainViewCell)
            cell.label.text = eventsData[indexPath.row].value!
            cell.label.sizeToFit()
            tableView.rowHeight = cell.label.frame.height + 6
            break
        default:
            break
        }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case tasksTable:
            return 2
        default:
            return 1
        }
    }
}


//-MARK:- JTAppleCalendar Delegate, Data source

extension MainViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy MM dd"
    let startDate = formatter.date(from: "2018 01 01")!
        let endDate = formatter.date(from: "2025 01 01")!
    return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
    let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
    cell.dateLabel.text = cellState.text
        if date.startOfDay == navBarController.currentDate.startOfDay {
            cell.markSelected()
        }
        else {
            cell.markDeselected()
        }
        if cellState.dateBelongsTo != .thisMonth {
            cell.dateLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }


    return cell
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DateCell
        cell.dateLabel.text = cellState.text
    }
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.calenderMonthLabel.text! = visibleDates.monthDates[0].date.getMonth()
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        navBarController.setNewDate(date: date)
        calendar.reloadData()
        if cellState.dateBelongsTo != .thisMonth {
            calendar.scrollToDate(date)
        } else {
        }
        UIView.animate(withDuration: 0.4) {
            self.dateLabel.isHidden = false
            self.calendarView.isHidden = true
        }

  
        refresh()
    }

}








