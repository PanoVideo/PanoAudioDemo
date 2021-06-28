//
//  PanoVoiceTableController.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2021/3/24.
//

import UIKit

class PanoVoiceTableController: UITableViewController {
    
    var selectedIndex = PanoClientService.audioVoiceChanger.rawValue;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
    @IBAction func finish(_ sender: Any) {
        PanoClientService.setAudioVoiceChangerMode(mode: PanoAudioVoiceChangerOption(rawValue: selectedIndex)!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pop(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
