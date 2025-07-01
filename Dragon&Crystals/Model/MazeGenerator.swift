import Foundation

class Maze{
    let width: Int
    let height: Int
    private var rooms: [[Room]]
    
    init(width: Int, height: Int, rooms: [[Room]]) {
        self.width = width
        self.height = height
        self.rooms = rooms
    }
    
    func room(at coordinates: Coordinates) -> Room?{
        guard coordinates.x >= 0 && coordinates.x < width &&
              coordinates.y >= 0 && coordinates.y < height else {
            return nil
        }
        return rooms[coordinates.y][coordinates.x]
    }
}

class MazeGenerator{
    let width: Int
    let height: Int
    
    
    init(width: Int, height: Int){
        self.height = height
        self.width = width
    }
    func generate() -> (maze: Maze, player: Player, initialSteps: Int)? {
           let maxAttempts = 500
           var minInitialSteps: Int
           var maxInitialSteps: Int
           for _ in 0..<maxAttempts {
               var grid = [[Room?]] (repeating: [Room?] (repeating: nil, count: width), count: height)
               var visited = Set<Coordinates>()

               let startGenCoords = Coordinates(x: Int.random(in: 0..<width), y: Int.random(in: 0..<height))
               
            
               dig(from: startGenCoords, grid: &grid, visited: &visited)

               let allRoomsCount = width * height
               let generatedRoomsCount = grid.flatMap { $0 }.compactMap { $0 }.count

               guard generatedRoomsCount == allRoomsCount else {
                   consoleView.display("Warning: Maze generation failed to connect all rooms (\(generatedRoomsCount)/\(allRoomsCount) generated). Retrying...")
                  continue
                }

               var rooms: [[Room]] = []
               for y in 0..<height {
                   var row: [Room] = []
                   for x in 0..<width {
                       row.append(grid[y][x]!) 
                   }
                   rooms.append(row)
               }
               
               let maze = Maze(width: width, height: height, rooms: rooms)

               let allCoordinates = (0..<width).flatMap { x in (0..<height).map { y in Coordinates(x: x, y: y) } }
               guard let playerStartCoords = allCoordinates.randomElement(),
                     let keyCoords = allCoordinates.randomElement(),
                     let chestCoords = allCoordinates.randomElement(),
                     let torchlightCoords = allCoordinates.randomElement(),
                     let darkRoomCoord = allCoordinates.randomElement() else {
                   continue
               }
               var n = width > 4 ? 3 : 2
               while n != 0{
                   var prevFoodCoords: Coordinates?
                   guard var foodCoords = allCoordinates.randomElement() else {
                       continue
                   }
                   while(prevFoodCoords == foodCoords){
                       foodCoords = allCoordinates.randomElement()!
                   }
                   n -= 1;
                  prevFoodCoords = foodCoords
                   maze.room(at: foodCoords)?.items.append(.food)
                   
               }
               
               if keyCoords == chestCoords { continue }
               if keyCoords == darkRoomCoord || chestCoords == darkRoomCoord { continue }
               if playerStartCoords == darkRoomCoord { continue }
               if playerStartCoords == keyCoords || playerStartCoords == chestCoords { continue }
               if(torchlightCoords == darkRoomCoord){continue}
            

               maze.room(at: keyCoords)?.items.append(.key)
               maze.room(at: chestCoords)?.items.append(.chest)
               maze.room(at: torchlightCoords)?.items.append(.torchlight)
               maze.room(at: darkRoomCoord)?.addDarkRoom(coordinates: darkRoomCoord)

               let (keyReachable, keyPathLength) = isReachable(from: playerStartCoords, to: keyCoords, in: maze)
               let (chestReachable, chestPathLength) = isReachable(from: keyCoords, to: chestCoords, in: maze)
               minInitialSteps = keyPathLength + chestPathLength + width
               maxInitialSteps =  minInitialSteps + width * 10

               let initialSteps = Int.random(in: minInitialSteps...maxInitialSteps)
               let player = Player(playersteps: initialSteps, currentroomCoordinates: playerStartCoords)

               if keyReachable && chestReachable && keyPathLength + chestPathLength <= initialSteps {
                   consoleView.display("Лабиринт успешно сгенерирован и проходим. Начальных шагов: \(initialSteps)")
                   return (maze, player, initialSteps)
               } else {
                   consoleView.display("Сгенерированный лабиринт не соответствует условиям (непроходим или слишком длинный путь). Повторная попытка...")
                   maze.room(at: keyCoords)?.items.removeAll(where: { $0 == .key })
                   maze.room(at: chestCoords)?.items.removeAll(where: { $0 == .chest })
               }
           }
        consoleView.display("Не удалось сгенерировать подходящий лабиринт после \(maxAttempts) попыток.")
           return nil
       }
    
    
    
    private func dig(from current: Coordinates, grid: inout  [[Room?]],  visited: inout  Set<Coordinates>){
        if grid[current.y][current.x] == nil {
            grid[current.y][current.x] = Room(y: current.y, x: current.x)
        }
        visited.insert(current)
        for direction in Directions.allCases.shuffled(){
            let neighbours = current.neighbour(in: direction)
        
            guard neighbours.x >= 0 && neighbours.x < width && neighbours.y >= 0 && neighbours.y < height && !visited.contains(neighbours) else{ continue}
            
            if grid[neighbours.y][neighbours.x] == nil{
                grid[neighbours.y][neighbours.x] = Room( y: neighbours.y, x: neighbours.x)
            
            }
            grid[current.y][current.x]?.addDoor(direction)
            grid[neighbours.y][neighbours.x]?.addDoor(direction.opposite)
            
            dig(from: neighbours, grid: &grid, visited: &visited)
            
        }
    }
    private func isReachable(from start: Coordinates, to end: Coordinates, in  maze: Maze) -> (Bool, Int) {
        var queue = [(Coordinates, Int)]()
        var visited = Set<Coordinates>()
        
        queue.append((start, 0))
        visited.insert(start)
        
        while !queue.isEmpty{
            let (current, steps) = queue.removeFirst()
            
            if current == end{
                return (true, steps)
            }
            guard let currentRoom = maze.room(at: current) else { continue }
            
            for direction in currentRoom.doors{
                let neighbours = current.neighbour(in: direction)

                
                if !visited.contains(neighbours) && maze.room(at: neighbours) != nil{
                    queue.append((neighbours, steps + 1))
                    visited.insert(neighbours)
                }
                
            }
            
        }
        return(false, 0)
    }
        
        
    
    
    
}
