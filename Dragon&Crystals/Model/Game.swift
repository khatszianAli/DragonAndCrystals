class Game{
    var player: Player
    var maze: Maze
    var gameOver = false
    var gameWin = false
    
    init(player: Player, maze: Maze){
        self.player = player
        self.maze = maze
    }
    func drawRoom(){
        var matrix = [
            ["*", " *", " *", " *", " *"],
            ["*", " *", " *", " *", " *"],
            ["*", " *", " P", " *", " *"],
            ["*", " *", " *", " *", " *"],
            ["*", " *", " *", " *", " *"],
        ]
        if let current = maze.room(at: player.currentroomCoordinates){
            for door in current.doors{
                switch door{
                case .north:
                    matrix[0][2] = " N"
                case .east:
                    matrix[2][4] = " E"
                case .south:
                    matrix[4][2] = " S"
                case .west:
                    matrix[2][0] = "W"
                }
            }
        }
        guard let current = maze.room(at: player.currentroomCoordinates) else{return}
        
        if current.items.contains(.key){
            matrix[2][1] = " K"
        }
       if current.items.contains(.chest){
           matrix[2][3] = " C"
        }
        if current.items.contains(.torchlight){
            matrix[1][2] = " T"
        }
        if current.items.contains(.food){
            matrix[3][2] = " F"
        }
        for row in matrix{
            print(row.joined())
            
        }
    }
    func tryMove(direction: Directions) -> Bool{
        guard let current = maze.room(at: player.currentroomCoordinates) else{return false}
        
        if current.doors.contains(direction){
            let newCoordinates = player.currentroomCoordinates.neighbour(in: direction)
            if maze.room(at: newCoordinates) != nil{
                player.move(to: newCoordinates)
                return true
            }
        }
        return false
    }
    func tryGetItem(item: String) -> Bool{
        guard let current = maze.room(at: player.currentroomCoordinates) else{return false}
        
        if let itemIndex = current.items.firstIndex(where: {$0.name.lowercased() == item.lowercased()}){
            let pick = current.items.remove(at: itemIndex)
            player.get_item(pick)
            return true
        }
        return false
    }
    func tryDropItem(item: String) -> Bool{
        guard let current = maze.room(at: player.currentroomCoordinates) else{return false}
        
        if let drop = player.drop_item(item){
            current.items.append(drop)
            return true
        }
        return false
    }
    func tryEat(item: String) -> Bool{
        if player.inventory.contains(.food){
            player.playersteps += Int.random(in: 5...15)
            if let index = player.inventory.firstIndex(of: .food){
                player.inventory.remove(at: index)
            }
            
            return true
        }
        return false
    }
    func openChest() -> Bool{
        guard let current = maze.room(at: player.currentroomCoordinates) else{return false}
        
        let chestInRoom = current.items.contains(Item.chest)
        let hasKey = player.inventory.contains(Item.key)
        
        if chestInRoom && hasKey{
            print("Вы открыли сундук ключом! Внутри вы находите священный Грааль!")
            print("ПОБЕДА! Вы выиграли игру!")
            gameWin = true
            gameOver = true
            return true
        }else if !chestInRoom{
            print("В этом комнате нет сундука!")
        }else{
            print("У вас нет ключа, чтобы открыть этот сундук.")
        }
        return false
    }
    func checkDarkRoom()-> Bool{
        guard let current = maze.room(at: player.currentroomCoordinates)
        else{return false}
        
        let darkRoom = current.coordDarkRoom
        let hasTorchlight = player.inventory.contains(Item.torchlight)
        let tourchlihgtInRoom = current.items.contains(Item.torchlight)
        
        if(player.currentroomCoordinates == darkRoom && !hasTorchlight && !tourchlihgtInRoom){
            return true
        }
        return false
    }
    func checkLoss(){
        if player.playersteps <= 0{
            print("У вас закончились шаги, и вы умерли от голода в мрачных застенках драконьей пещеры.")
            print("ПОРАЖЕНИЕ! Игра окончена.")
            gameOver = true
        }
    }
}
