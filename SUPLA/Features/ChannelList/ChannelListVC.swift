/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

import Foundation

class ChannelListVC : ChannelBaseTableViewController<ChannelListViewState, ChannelListViewEvent, ChannelListViewModel> {
    
    private var captionEditor: ChannelCaptionEditor? = nil
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        viewModel = ChannelListViewModel()
    }
    
    override func getCollapsedFlag() -> CollapsedFlag { .channel }
    
    override func handle(event: ChannelListViewEvent) {
        switch(event) {
        case .navigateToDetail(let legacyDetailType, let channelBase):
            navigator?.navigateToLegacyDetail(legacyDetailType: legacyDetailType, channelBase: channelBase)
        case .navigateToStandardDetail(let remoteId, let pages):
            navigator?.navigateToStandardDetail(remoteId: remoteId, pages: pages)
        }
    }
    
    override func configureCell(channelBase: SAChannelBase, indexPath: IndexPath) -> UITableViewCell {
        let cell = super.configureCell(channelBase: channelBase, indexPath: indexPath) as! SAChannelCell
        cell.delegate = self
        
        return cell
    }
    
    override func captionEditorDidFinish(_ editor: SACaptionEditor) {
        if (editor == captionEditor) {
            captionEditor = nil
            tableView.reloadData()
        } else {
            super.captionEditorDidFinish(editor)
        }
    }
}

extension ChannelListVC: SAChannelCellDelegate {
    func channelButtonClicked(_ cell: SAChannelCell!) {
    }
    
    func channelCaptionLongPressed(_ remoteId: Int32) {
        vibrationService.vibrate()
        
        captionEditor = ChannelCaptionEditor()
        captionEditor?.delegate = self
        captionEditor?.editCaption(withRecordId: remoteId)
    }
}
