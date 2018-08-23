//
//  ViewController.swift
//  DFPTest
//
//  Created by Eugene Dorfman on 20/4/18.
//  Copyright © 2018 Postindustria. All rights reserved.
//

import UIKit
import GoogleMobileAds

enum BannerWidthChoice: Int {
    case fixedSize = 0
    case flexible = 1
}

class ViewController: UIViewController, GADBannerViewDelegate {
    
    private let adUnitId = "/24074087/StockMarketHD"
    
    @IBOutlet weak var bannerWidthSegmentedControl: UISegmentedControl!
    @IBOutlet weak var bannerLoadingStatus: UILabel!
    var bannerView: DFPBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // In this case, we instantiate the banner with desired ad size.
        bannerView = DFPBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.validAdSizes = [
            NSValueFromGADAdSize(kGADAdSizeMediumRectangle),
            NSValueFromGADAdSize(kGADAdSizeSmartBannerLandscape),
            NSValueFromGADAdSize(kGADAdSizeSmartBannerPortrait)
        ]
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.layer.borderColor = UIColor.red.cgColor
        bannerView.layer.borderWidth = 2
        addBannerViewToView(bannerView)
    }

    private lazy var heightConstraint =
    {
        NSLayoutConstraint(item: bannerView,
                           attribute: NSLayoutAttribute.height,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute,
                           multiplier: 1,
                           constant: 250)
    }()

    private lazy var bottomConstraint =
    {
        NSLayoutConstraint(item: bannerView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: view.safeAreaLayoutGuide,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0)
        
    }()
    
    private lazy var fixedWidthConstraints = {
        [
            heightConstraint,
            bottomConstraint,
            NSLayoutConstraint(item: bannerView,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerX,
                               multiplier: 1,
                               constant: 0)
        ]
    }()
    
    private lazy var flexibleConstraints = {
        [
            heightConstraint,
            bottomConstraint,
            NSLayoutConstraint(item: self.bannerView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0),
            NSLayoutConstraint(item: self.bannerView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: self.view,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0)
        ]
    }()
    
    
    func addBannerViewToView(_ bannerView: DFPBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        let defaultChoice = BannerWidthChoice.flexible
        bannerWidthSegmentedControl.selectedSegmentIndex = defaultChoice.rawValue
        processBannerWidthChoice(defaultChoice)
    }
    
    private func reloadBanner() {
        let request = DFPRequest()
        request.testDevices = [ kGADSimulatorID ]
        bannerView.load(request)
        self.bannerLoadingStatus.text = "loading"
    }

    func processBannerWidthChoice(_ choice: BannerWidthChoice) {
        view.removeConstraints(flexibleConstraints)
        view.removeConstraints(fixedWidthConstraints)
        switch choice {
        case .fixedSize:
            view.addConstraints(fixedWidthConstraints)
        case .flexible:
            view.addConstraints(flexibleConstraints)
        }
        reloadBanner()
    }

    //MARK: - GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.bannerLoadingStatus.text = "did receive ad"
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        self.bannerLoadingStatus.text = "failed to receive ad: \(error.localizedDescription)"
    }
    
    //MARK: segmented control
    @IBAction func bannerWidthChanged(_ sender: UISegmentedControl) {
        if let choice = BannerWidthChoice(rawValue: sender.selectedSegmentIndex) {
            processBannerWidthChoice(choice)
        }
    }
    
    @IBAction func reloadBannerTapped(_ sender: UIButton) {
        reloadBanner()
    }

    @IBAction func openDebugOptions(sender: AnyObject) {
        let debugOptionsViewController = GADDebugOptionsViewController(adUnitID: adUnitId)
        self.present(debugOptionsViewController, animated: true, completion: nil)
    }
}

