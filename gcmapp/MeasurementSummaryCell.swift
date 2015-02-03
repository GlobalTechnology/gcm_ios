//
//  MeasurementSummaryCell.swift
//  gcmapp
//
//  Created by Jon Vellacott on 02/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import UIKit

class MeasurementSummaryCell: UITableViewCell {

    @IBOutlet weak var lblRow: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
