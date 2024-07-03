//
//  DP_PhotoTableManager.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import UIKit

enum DP_PhotoEvent {
    case pined
    case recent
}

typealias DP_PhotoTableManagerExtension = DP_PhotoTableManager

class DP_PhotoTableManager: NSObject {
    
    var eventHandler: Block<(URL)>?
    private var tableView: UITableView
    private var data: [DP_PhotoModel] = []
    private let helper: DP_PhotoHelper = DP_PhotoHelper()
   
    init(_ tableView: UITableView) {

        self.tableView = tableView
        super.init()
        
        registerTableViewCells()
        data = helper.dp_getPhotos()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
}

extension DP_PhotoTableManagerExtension {
    
    func registerTableViewCells() {
        tableView.register(DP_PhotoCell.nib, forCellReuseIdentifier: DP_ConstantId.photoCell)
    }
    
    func dp_reloadTable() {
        tableView.reloadData()
    }
    
    func dp_reloadTableWithData(_ event: DP_PhotoEvent) {
        switch event {
        case .pined:
            data = helper.dp_getPinedPhotos()
        case .recent:
            data = helper.dp_getPhotos()
        }
        tableView.reloadData()
    }
}

extension DP_PhotoTableManagerExtension: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DP_ConstantId.photoCell, for: indexPath)
                as? DP_PhotoCell else { return UITableViewCell() }
        
        let model = data[indexPath.row]
        cell.dp_configure(model: model)
        return cell
    }
}

extension DP_PhotoTableManagerExtension: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        eventHandler?(data[indexPath.row].path)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        print("Deleted")

          helper.dp_deletePinedPhoto(url: data[indexPath.row].path)
          helper.dp_deletePhoto(url: data[indexPath.row].path)
          data.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
      }
    }
}

