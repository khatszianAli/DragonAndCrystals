protocol GameItem{
    var name: String { get }
    var isPickable: Bool { get }
}
enum Directions: String, CaseIterable{
    case north = "N"
    case south = "S"
    case west = "W"
    case east = "E"
    var opposite: Directions {
           switch self {
           case .north: return .south
           case .south: return .north
           case .west: return .east
           case .east: return .west
           }
       }
    }
enum Item: GameItem{
        case key
        case chest
        case torchlight
    var name: String{
        switch self {
        case .key:
            return "key"
        case .chest:
            return "chest"
        case .torchlight:
            return "torchlight"
        }
    
    }
    var isPickable: Bool{
        switch self{
        case .key:
            return true
        case .chest:
            return false
        case .torchlight:
            return true
        }
    }
}

class Room{
    var x: Int
    var y: Int
    private(set) var doors: Set<Directions>
    var coordDarkRoom: Coordinates
    var items: [Item]
    init(y: Int, x: Int, doors: Set<Directions> = [],coordDarkRoom: Coordinates = Coordinates(x: -1, y: -1), items: [Item] = []){
        self.x = x
        self.y = y
        self.doors = doors
        self.items = items
        self.coordDarkRoom = coordDarkRoom
    }
     func description() -> String{
         var desc = "You are in the room [\(x),\(y)].  There are \(doors.count) doors: \(doors.map { $0.rawValue }.joined(separator: ", "))"
        desc += " Items in the room: "
        if(items.isEmpty){
            desc += "none "
        }else{
            for item in items{
                desc += "\(item) "
            }
        }
        return desc
    }
    func addDarkRoom(coordinates: Coordinates){
        coordDarkRoom = coordinates
    }
    func addDoor(_ direction: Directions){
        doors.insert(direction)
    }
    func removeDoor(_ direction: Directions){
        doors.remove(direction)
    }
    
}
