//
//  LeftMenuCellBuilder.swift
//  Mattermost
//
//  Created by TaHyKu on 19.10.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

private protocol LeftMenuCellBuilderInteface: class {
    func cellHeight() -> CGFloat
    func cellFor(channel: Channel, indexPath: IndexPath) -> UITableViewCell
}


final class LeftMenuCellBuilder {

//MARK: Properties
    fileprivate let tableView: UITableView
    
//MARK: LifeCycle
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    private init?() {
        return nil
    }
}


//MARK: LeftMenuCellBuilderInteface
extension LeftMenuCellBuilder: LeftMenuCellBuilderInteface {
    func cellHeight() -> CGFloat {
        return 42
    }
    
    func cellFor(channel: Channel, indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier = ""
        switch indexPath.section {
        case 0:
            reuseIdentifier = PublicChannelTableViewCell.reuseIdentifier
        case 1:
            reuseIdentifier = PrivateChannelTableViewCell.reuseIdentifier
        case 2:
            reuseIdentifier = DirectChannelTableViewCell.reuseIdentifier
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LeftMenuTableViewCellProtocol
        cell.configureWithChannel(channel, selected: channel.isSelected)
        cell.test = {
            //FIXME: REFACTOR:!!!!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        return cell as! UITableViewCell
    }
}
