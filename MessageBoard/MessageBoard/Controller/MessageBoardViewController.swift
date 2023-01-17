//
//  MessageBoardViewController.swift
//  MessageBoard
//
//  Created by imac-2437 on 2023/1/17.
//

import UIKit

class MessageBoardViewController: UIViewController {
    @IBOutlet weak var messagePeopleLable: UILabel!
    @IBOutlet weak var messagePeopleTextField:UITextField!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    var messageArray: [Message] = []
    
    var optionsArray: [String] = ["預設", "舊到新" , "新到舊"]
    
    enum SortRule {
        case `default`
        case oldToNew
        case newToold
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    func setupUI() {
        setupLable()
        setupButton()
        setupTableView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func setupLable() {
        
        messagePeopleLable.text = "留言人"
        messageLable.text = "留言內容"
    }
    private func setupButton() {
        sendButton.setTitle("送出", for: .normal)
        sendButton.backgroundColor = .green
        sendButton.layer.cornerRadius = 10
        sortButton.setTitle("排序", for: .normal)
        sortButton.backgroundColor = .purple
        sortButton.layer.cornerRadius = 10

    }
    
    private func setupTableView() {
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: MessageTableViewCell.idenrifier)
        messageTableView.dataSource = self
        messageTableView.delegate = self
        
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    func showAlert(title: String?, message: String?, confirmTitle: String, confirm: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            confirm?()
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
    func showActionSheet(title: String?,
                         message: String? ,
                         options: [String],
                         confirm: ((Int) -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .actionSheet)
        
        for option in options {
            let index = options.firstIndex(of: option)
            let action = UIAlertAction(title: option, style: .default) { _ in
                    confirm?(index!)
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func sortMessage(rule: SortRule) -> [Message] {
        return messageArray.sorted(by: { prev, next in
            switch rule {
            case .default:
                return prev.timestap > next.timestap
            case .oldToNew:
                return prev.timestap < next.timestap
            case .newToold:
                return prev.timestap > next.timestap
            }
        })
    }
    
    @IBAction func sendBtnClicked(_ sender: UIButton) {
        closeKeyboard()
        guard let messagePeople = messagePeopleTextField.text, !(messagePeople.isEmpty) else {
            showAlert(title: "錯誤", message: "請輸入留言人", confirmTitle: "關閉")
            return
        }
        guard let message = messageTextView.text, !(message.isEmpty) else {
            showAlert(title: "錯誤", message: "請輸入留言", confirmTitle: "關閉")
            return
        }
        showAlert(title: "成功", message: "留言已送出", confirmTitle: "關閉") {
            self.messagePeopleTextField.text = ""
            self.messageTextView.text = ""
        }
        print("留言人：\(messagePeople)")
        print("留言內容：\(message)")
        messageArray.append(Message(name: messagePeople,
                                    content: message,
                                    timestap: Int64(Date().timeIntervalSince1970)))
        messageTableView.reloadData()
    }
    
    @IBAction func sortBtnClicked(_ sender: UIButton) {
        showActionSheet(title: "請選擇排序方式",
                        message: "我也不知道寫什麼",
                        options: optionsArray) { index in
            switch index {
            case 0:
                print("選擇預設排序方式")
                print(self.sortMessage(rule: .default))
            case 1:
                print("選擇舊到新排序方式")
                print(self.sortMessage(rule: .oldToNew))
            case 2:
                print("選擇新到舊排序方式")
                print(self.sortMessage(rule: .newToold))
            default:
                break
            }
        }
    }

}

extension MessageBoardViewController: UITableViewDataSource, UITableViewDelegate {
    
    //UITableViewDataSource
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.idenrifier,
                                                       for: indexPath) as? MessageTableViewCell else {
            fatalError("MessageTableViewCell Load Failed")
        }
        cell.messagePeopleLable.text = "留言人：" + messageArray[indexPath.row].name
        cell.messageLable.text = "留言內容：" + messageArray[indexPath.row].content
        return cell
    }
    
    //UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    //UI 左滑
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deletedAction = UIContextualAction(style: .destructive, title: "刪除") { action, sourceView, completionHandler in
            self.messageArray.remove(at: indexPath.row)
            tableView.reloadData()
            completionHandler(true)
        }
        deletedAction.image = UIImage(systemName: "trash")
        deletedAction.backgroundColor = .blue
        let configuration = UISwipeActionsConfiguration(actions: [deletedAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    //右滑
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editedAction = UIContextualAction(style: .destructive, title: "編輯"){ action, sourceView, completionHandler in
            tableView.reloadData()
            completionHandler(true)
        }
        editedAction.image = UIImage(systemName: "pencil")
        editedAction.backgroundColor = .systemBrown
        let configuration = UISwipeActionsConfiguration(actions: [editedAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
