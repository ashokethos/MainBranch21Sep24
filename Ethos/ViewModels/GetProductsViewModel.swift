//
//  GetProductsViewModel.swift
//  Ethos
//
//  Created by mac on 23/08/23.
//

import Foundation
import Mixpanel

class GetProductViewModel : NSObject {
    var minPriceLimit : Int?
    var maxPriceLimit : Int?
    
    var upperPriceLimit : Int?
    var lowerPriceLimit : Int?
    
    var limit = 20
    var product : Product?
    var products = [Product]()
    var similarProducts = [ProductLite]()
    var betterTogetherProducts = [ProductLite]()
    var categoryId : Int?
    var categoryName : String?
    var filterProductCount = 0
    var currentDataCount = 0
    var currentPage = 1
    var totalCount = 0
    var isExpanded = false
    var gettingNewProducts = false
    var filters = [FilterModel]()
    var selectedFilter : FilterModel?
    var selectedFilters = [FilterModel]()
    var selectedValues = [SelectedFilterData]()
    var delegate : GetProductViewModelDelegate?
    
    var selectedSortBy : String? = EthosConstants.bestSeller {
        didSet {
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.CatalogSortingUsed,
                properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : self.categoryName,
                    EthosConstants.TypeOfSort : self.selectedSortBy
                ]
            )
        }
    }
    
    var defaultSortBy : String? = EthosConstants.bestSeller
    
    var availableSortBy = [EthosConstants.bestSeller, EthosConstants.priceLowToHigh, EthosConstants.priceHighToLow, EthosConstants.NewArrivals.uppercased()]
    
    var filterData : FilterData? {
        let filterData = FilterData()
        let reversedArray = selectedFilters.reversed()
        for filter in reversedArray {
            filterData.setchild(model: filter)
        }
        return filterData.child
    }
    
    func initiate(id: Int?, categoryName: String? = nil, limit : Int? = nil, selectedSortBy : String? = nil, completion : (() -> ())? = nil) {
        
        self.categoryId = id
        
        if let limit = limit {
            self.limit = limit
        }
        
        if let categoryName = categoryName {
            self.categoryName = categoryName
        }
        
        if let selectedSortBy = selectedSortBy {
            self.selectedSortBy = selectedSortBy
        }
        
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                completion()
            }
        }
        
    }
    
    func getSelectedValuesFromSelectedFilters() -> [SelectedFilterData] {
        var arrSelectedValues = [SelectedFilterData]()
        for filter in selectedFilters {
            for value in filter.values ?? [] {
                let selectedModel = SelectedFilterData(filterModelName: filter.attributeName ?? "", filterModelCode: filter.attributeCode ?? "", filterModelId: filter.attributeId ?? 0, filtervalue: value)
                
                arrSelectedValues.append(selectedModel)
            }
        }
        return arrSelectedValues
    }
    
    
    func getSelectedFiltersFromSelectedValues() -> [FilterModel] {
        var selectedFilters = [FilterModel]()
        
        for selectedValue in selectedValues {
            if selectedFilters.contains(where: { filter in
                filter.attributeName == selectedValue.filterModelName
            }) {
                
                if let index = selectedFilters.firstIndex(where: { element in
                    element.attributeName == selectedValue.filterModelName
                }), index < selectedFilters.count {
                    selectedFilters[index].values?.append(selectedValue.filtervalue)
                    
                }
                
                
            } else {
                
                let filterModel = FilterModel(attributeId: selectedValue.filterModelId, attributeCode: selectedValue.filterModelCode, attributeName: selectedValue.filterModelName, values: [selectedValue.filtervalue])
                selectedFilters.append(filterModel)
                
            }
        }
        
        return selectedFilters
    }
    
    
    
    
    func getProductsFromCategory (
        site : Site = .ethos,
        searchString : String = ""
    ) {
        guard let id = self.categoryId else { return }
        
        var filters : [String : Any]? = nil
        
        if (self.selectedSortBy != nil || self.selectedFilters.count > 0) && searchString == "" {
            filters = getRequestBodyFromData()
        }
        
        self.delegate?.startIndicator()
        
        var body = [String: Any]()
        var requestType = RequestType.GET
        var params : [String : String] = [
            EthosConstants.site : site.rawValue,
            EthosConstants.limit : String(self.limit),
            EthosConstants.productString : searchString,
            EthosConstants.page : "1",
        ]
        
        if let filters = filters {
            requestType = .POST
            body = filters
        } else {
            params[EthosConstants.category] = String(id)
        }
        
        EthosApiManager().callApi (
            endPoint : filters != nil ? EthosApiEndPoints.getFilteredProducts : EthosApiEndPoints.getProducts,
            RequestType : requestType,
            RequestParameters : params,
            RequestBody : body
        ) { data, response, error in
            if let response = response as? HTTPURLResponse {
                self.delegate?.stopIndicator()
                if response.statusCode == 200 {
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                        let products = GetProducts(json: json)
                        self.currentDataCount = products.data?.currentDataCount ?? 0
                        self.currentPage = products.data?.currentPage ?? 0
                        self.totalCount = products.data?.totalCount ?? 0
                        self.products = products.data?.products ?? [Product]()
                        self.delegate?.didGetProducts(site: site, CategoryId: id)
                    }
                } else {
                    self.delegate?.errorInGettingProducts(error: EthosConstants.error)
                }
            }
        }
    }
    
    
    func getNewProducts (
        site : Site = .ethos,
        searchString : String = ""
    ) {
        
        guard let id = self.categoryId else { return }
        
        var filters : [String : Any]? = nil
        
        if (self.selectedSortBy != nil || self.selectedFilters.count > 0) && searchString == "" {
            filters = self.getRequestBodyFromData()
        }
        
        if !self.gettingNewProducts,
           currentDataCount >= limit,
           self.products.count < totalCount {
            currentPage += 1
            self.gettingNewProducts = true
            self.delegate?.startFooterIndicator()
            
            var requestBody : [String : Any] = [String : Any]()
            var requestType : RequestType = .GET
            
            var params : [String:String] = [
                EthosConstants.site : site.rawValue,
                EthosConstants.limit : String(self.limit),
                EthosConstants.page : String(self.currentPage),
                EthosConstants.productString : searchString
            ]
            
            if let filters = filters {
                requestBody = filters
                requestType = .POST
                
            } else {
                params[EthosConstants.category] = String(id)
            }
            
            EthosApiManager().callApi(
                endPoint: filters != nil ? EthosApiEndPoints.getFilteredProducts : EthosApiEndPoints.getProducts,
                RequestType: requestType,
                RequestParameters: params,
                RequestBody:  requestBody
            ) { data, response, error in
                self.gettingNewProducts = false
                self.delegate?.stopFooterIndicator()
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                            let products = GetProducts(json: json)
                            self.currentDataCount = products.data?.currentDataCount ?? 0
                            self.currentPage = products.data?.currentPage ?? 0
                            self.totalCount = products.data?.totalCount ?? 0
                            let newProducts = products.data?.products ?? [Product]()
                            self.products.append(contentsOf: newProducts)
                            self.delegate?.didGetProducts(site: site, CategoryId: id)
                        }
                    }
                }
            }
        }
    }
    
    func getRequestBodyFromData() -> [String : Any] {
        guard let id = self.categoryId else {
            return [String : Any]()
        }
        
        var requestBody = [String: Any]()
        var filters = [String : Any]()
        filters[EthosConstants.categoryId] = ["\(id)"]
        
        if let selectedSortBy = self.selectedSortBy {
            if selectedSortBy == EthosConstants.priceHighToLow {
                requestBody[EthosConstants.sorting] = [EthosConstants.key : EthosConstants.price , EthosConstants.value : EthosConstants.desc]
            } else if selectedSortBy == EthosConstants.priceLowToHigh {
                requestBody[EthosConstants.sorting] = [EthosConstants.key : EthosConstants.price , EthosConstants.value : EthosConstants.asc]
            } else if selectedSortBy == EthosConstants.bestSeller {
                requestBody[EthosConstants.sorting] = [EthosConstants.key : EthosConstants.position , EthosConstants.value : EthosConstants.asc]
            } else if selectedSortBy == EthosConstants.NewArrivals {
                requestBody[EthosConstants.sorting] = nil
            }
        }
        
        if self.selectedFilters.count > 0 {
            for filter in self.selectedFilters {
                if let key = filter.attributeCode {
                    var arrvalues = [[String : String]]()
                    for val in filter.values ?? [] {
                        if let attrName = val.attributeValueName {
                            var dict = [String : String]()
                            if let attrid = val.attributeValueId {
                                dict[EthosConstants.attrValueID] = String(attrid)
                            }
                            dict[EthosConstants.attrValueName] = String(attrName)
                            arrvalues.append(dict)
                        }
                    }
                    filters[key] = arrvalues
                }
            }
        }
        
        requestBody[EthosConstants.filters] = filters
        return requestBody
    }
    
    func getProductDetails (
        sku : String,
        site : Site = .ethos
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi (
            endPoint: EthosApiEndPoints.getProducts + EthosConstants.slash + (sku.replacingOccurrences(of: EthosConstants.slash, with: EthosConstants.slashMark)),
            RequestType: .GET,
            RequestParameters: [EthosConstants.site : site.rawValue, "v" : "2"],
            RequestBody: [:]
        ) { data, response, error in
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
               let status = json[EthosConstants.status] as? Bool,
               status == true,
               let prodctData = json[EthosConstants.data] as? [String : Any] {
                self.product = Product(json: prodctData)
                
                if let similarProducts = json[EthosConstants.similarProducts] as? [[String : Any]] {
                    var arrSmilarProducts = [ProductLite]()
                    for sp in similarProducts {
                        let product = ProductLite(json: sp)
                        
                        if product.sku != nil {
                            arrSmilarProducts.append(product)
                        }
                        
                    }
                    self.similarProducts = arrSmilarProducts
                } else {
                    self.similarProducts = []
                }
                
                if let details = self.product {
                    self.delegate?.didGetProductDetails(details: details)
                }
                
            } else {
                self.delegate?.failedToGetProductDetails()
            }
        }
    }
    
    func getFilters(site : Site, screenType: String?) {
        guard let id = self.categoryId else { return }
        var params = [String : Any]()
        var hasSelectedFilters = false
        if let filters = self.filterData {
            params[EthosConstants.filters] = filters.getDictionary()
            hasSelectedFilters = true
        }
        self.delegate?.startIndicator()
        EthosApiManager().callApi(endPoint: hasSelectedFilters ? EthosApiEndPoints.getFiltersByAttribute : EthosApiEndPoints.getFilters, RequestType: hasSelectedFilters ? .POST : .GET, RequestParameters: [EthosConstants.site : site.rawValue, EthosConstants.categoryId : String(id)], RequestBody: params) { data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               let data = data ,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
               json[EthosConstants.status] as? Bool == true,
               let jsonData = json[EthosConstants.data] as? [String : Any],
               let items = jsonData[EthosConstants.items] as? [[String : Any]] {
                
                var filters = [FilterModel]()
                for item in items {
                    let filter = FilterModel(json: item)
                    
                    if filter.attributeName?.uppercased() == "PRICE MAX" {
                        if let maxPriceStr = filter.values?.first?.attributeValueName, let maxprice = Int(maxPriceStr) {
                            if self.upperPriceLimit == nil {
                                self.maxPriceLimit = maxprice
                            }
                            
                        }
                    } else if filter.attributeName?.uppercased() == "PRICE MIN" {
                        if let minPriceStr = filter.values?.first?.attributeValueName, let minprice = Int(minPriceStr) {
                            if self.lowerPriceLimit == nil {
                                self.minPriceLimit = minprice
                            }
                        }
                    } else if filter.values?.count ?? 0 > 1 {
                        filters.append(filter)
                    }
                    
                }
                
                if filters.contains(where: { model in
                    model.attributeName?.uppercased() == EthosConstants.brand.uppercased()
                }) && !(self.getSelectedFiltersFromSelectedValues().contains(where: { model in
                    model.attributeName?.uppercased() == EthosConstants.brand.uppercased()
                })) {
                    if screenType == "search" || screenType == "view_all"{
                        filters.removeAll { model in
                            model.attributeName?.uppercased() == EthosConstants.collection.uppercased() || model.attributeName?.uppercased() == EthosConstants.series.uppercased()
                        }
                    }
                }
                
                if !filters.contains(where: { model in
                    model.attributeName?.uppercased() == "PRICE"
                }) {
                    if self.lowerPriceLimit != nil && self.upperPriceLimit != nil {
                        filters.append(FilterModel(attributeName: "PRICE"))
                    }
                }
                
                self.filters = filters.sorted(by: { a, b in
                    b.attributeName ?? "" > a.attributeName ?? ""
                })
                
                self.delegate?.didGetFilters()
            } else {
                self.delegate?.errorInGettingFilters()
            }
        }
    }
    
    func betterTogether (
        sku : String,
        site : Site = .ethos
    ) {
        self.delegate?.startIndicator()
        EthosApiManager().callApi (
            endPoint : EthosApiEndPoints.betterTogether + sku.replacingOccurrences(of: EthosConstants.slash, with: EthosConstants.slashMark),
            RequestType: .GET,
            RequestParameters: [
                EthosConstants.site : site.rawValue,
                "v" : "2"
            ],
            RequestBody: [:]
        ) { data, response, error in
            self.delegate?.stopIndicator()
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200, let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
               let jsonData = json[EthosConstants.data] as? [[String : Any]] {
                
                var productArr = [ProductLite]()
                for productJson in jsonData {
                    let product = ProductLite(json: productJson)
                    
                    if product.sku != nil {
                        productArr.append(product)
                    }
                }
                self.betterTogetherProducts = productArr
                self.delegate?.didGetProducts(site: site, CategoryId: nil)
            } else {
                DispatchQueue.main.async {
                    let httpresponse = response as? HTTPURLResponse
                    var strCode : String?
                    if let code = httpresponse?.statusCode {
                        strCode = String(code)
                    }
                    self.delegate?.errorInGettingProducts(error: (error?.localizedDescription ?? strCode) ?? EthosConstants.error)
                }
            }
        }
    }
}

extension FilterData {
    
    func setchild(model : FilterModel) {
        let data = model.getData()
        if self.child == nil {
            self.child = data
        } else {
            self.child?.setchild(model: model)
        }
    }
    
}

extension FilterModel {
    func getData() -> FilterData? {
        if let attrcode = self.attributeCode, let attrValues = self.values {
            let data = FilterData(attributes: FilterDataAttributes(attributeCode: attrcode, attributeValues: attrValues.map({ value in
                String(value.attributeValueId ?? 0)
            })))
            
            return data
        } else {
            return nil
        }
    }
}
