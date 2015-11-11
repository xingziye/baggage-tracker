//
//  BaggageTableViewCell.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 10/17/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit

class BaggageTableViewCell: UITableViewCell {
    @IBOutlet weak var bagNameLabel: UILabel!
    @IBOutlet weak var bagInfoLabel: UILabel!
    @IBOutlet weak var bagImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
