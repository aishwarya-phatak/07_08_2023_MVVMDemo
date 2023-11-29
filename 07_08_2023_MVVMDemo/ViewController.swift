//
//  ViewController.swift
//  07_08_2023_MVVMDemo
//
//  Created by Vishal Jagtap on 29/11/23.
//

import UIKit
//Observable
//Model
//ViewModel
//Controller

class Observable<T>{
    var value : T?{
        didSet{
            listener?(value)
        }
    }
    
    init(value: T? = nil) {
        self.value = value
    }
    
    private var listener : ((T?)->Void)?
    
    func bind(_ listener : ((T?)->Void)?){
        listener!(value)
        self.listener = listener
    }
}

//Model
struct User : Codable{
    let name : String
}

//ViewModel
//create UserListViewModel
struct UserListViewModel{
    var users : Observable<[UserTableViewCellViewModel]> = Observable(value: [])
}

//UserTableViewCellViewModel
struct UserTableViewCellViewModel{
    let name : String
}

class ViewController: UIViewController, UITableViewDataSource{
    
    private let tableView : UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var viewModel = UserListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromJSON()
        viewModel.users.bind { [weak self] _
            in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        self.view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.users.value![indexPath.row].name
        return cell
    }
    
    func fetchDataFromJSON(){
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return  }
        
        let task = URLSession.shared.dataTask(with: url) { [self] data, response, error in
            guard let data = data else {return}
            do {
                
                let userModels = try JSONDecoder().decode([User].self, from: data)
                //print(viewModel.users.value)
                self.viewModel.users.value = userModels.compactMap({
                    UserTableViewCellViewModel(name: $0.name)
                })
            }catch{
                print(error)
            }
        }
        task.resume()
    }
}
