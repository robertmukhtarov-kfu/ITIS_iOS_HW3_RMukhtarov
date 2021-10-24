import Foundation

protocol Product {
    var weight: Double { get }
}

// MARK: - Generics

struct ProductBox<T: Product> {
    let items: [T]
    
    var weight: Double {
        items.reduce(0.0) { $0 + $1.weight }
    }
}

extension ProductBox: CustomStringConvertible where T: CustomStringConvertible {
    var description: String {
        var description = "The box contains the following items:\n"
        for (index, item) in items.enumerated() {
            description += "\(index + 1). \(item.description)\n"
        }
        return description
    }
}

// MARK: - Protocol with associatedtype

protocol Factory {
    associatedtype FactoryProduct: Product
    
    func produce() -> ProductBox<FactoryProduct>
}

struct Smartphone: Product, CustomStringConvertible {
    let weight: Double
    let color: String
    
    var description: String {
        "Smartphone. Specs: weight: \(weight) kg, color: \(color)"
    }
}

struct BlueSmartphoneFactory: Factory {
    func produce() -> ProductBox<Smartphone> {
        let bluePhones = Array(
            repeating: Smartphone(weight: 0.137, color: "Blue"),
            count: 3
        )
        // Generics Usage Example
        return ProductBox(items: bluePhones)
    }
}

struct RedSmartphoneFactory: Factory {
    func produce() -> ProductBox<Smartphone> {
        let redPhones = Array(
            repeating: Smartphone(weight: 0.137, color: "Red"),
            count: 3
        )
        return ProductBox(items: redPhones)
    }
}

// MARK: - Type Erasure

private class _AnyFactoryWrapper<FactoryProduct: Product>: Factory {
    func produce() -> ProductBox<FactoryProduct> {
        fatalError("This method is abstract")
    }
}

private class _FactoryWrapper<Base: Factory>: _AnyFactoryWrapper<Base.FactoryProduct> {
    private let _base: Base
    
    init(_ base: Base) {
        _base = base
    }
    
    override func produce() -> ProductBox<FactoryProduct> {
        _base.produce()
    }
}

struct AnyFactory<FactoryProduct: Product>: Factory {
    private let _wrapper: _AnyFactoryWrapper<FactoryProduct>
    
    init<FactoryType: Factory>(_ factory: FactoryType) where FactoryType.FactoryProduct == FactoryProduct {
        _wrapper = _FactoryWrapper(factory)
    }
    
    func produce() -> ProductBox<FactoryProduct> {
        _wrapper.produce()
    }
}

struct SmartphoneCompany {
    let factory: AnyFactory<Smartphone>
}

// MARK: - Protocols and Type Erasure Usage Example

let redSmartphoneCompany = SmartphoneCompany(factory: AnyFactory(RedSmartphoneFactory()))
let blueSmartphoneCompany = SmartphoneCompany(factory: AnyFactory(BlueSmartphoneFactory()))

let redSmartphonesBox = redSmartphoneCompany.factory.produce()
print("Red Smartphone Company produced a box of smartphones")
print(redSmartphonesBox.description)

let blueSmartphoneBox = blueSmartphoneCompany.factory.produce()
print("Blue Smartphone Company produced a box of smartphones")
print(blueSmartphoneBox.description)
