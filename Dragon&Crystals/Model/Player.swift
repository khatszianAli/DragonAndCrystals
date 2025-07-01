import Foundation

struct Coordinates: Hashable{
    let x: Int
    let y: Int
    
    func neighbour(in directions: Directions) -> Coordinates{
        switch directions{
        case .north:
            return Coordinates(x: x, y: y + 1)
        case .south:
            return Coordinates(x: x, y: y - 1)
        case .east:
            return Coordinates(x: x + 1, y: y)
        case .west:
            return Coordinates(x: x - 1, y: y)
        }
    }
}
class Player{
    var playersteps: Int
    var inventory: [Item]
    var currentroomCoordinates: Coordinates
    
    init(playersteps: Int, currentroomCoordinates: Coordinates) {
        self.playersteps = playersteps
        self.inventory = []
        self.currentroomCoordinates = currentroomCoordinates
    }
    func move(to newCoordinates: Coordinates){
        self.currentroomCoordinates = newCoordinates
        self.playersteps -= 1
    }
    
    func get_item(_ item: Item){
        if(item.isPickable){
            inventory.append(item)
            consoleView.display("Вы подобрали \(item.name).")
        }else{
            consoleView.display( "Вы не можете поднять этот предмет.")
        }
        
    }
    func drop_item(_ itemName: String) -> Item?{
        if let index = inventory.firstIndex(where: { $0.name.lowercased()==itemName.lowercased() }) {
                    let removedItem = inventory.remove(at: index)
            consoleView.display("Вы выбросили \(removedItem.name).")
                return removedItem
                }
        return nil
    }
    func showInventory(){
        if inventory.isEmpty{
            consoleView.display("Ваш инвентарь пуст")
        }else{
            let items = inventory.map{$0.name}.joined(separator: ", ")
            consoleView.display("Ваш инвентарь: \(items)")
        }
    }
}
