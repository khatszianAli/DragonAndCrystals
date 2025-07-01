class GameController {
    private var game: Game?
    private let consoleView: ConsoleView

    init(consoleView: ConsoleView) {
        self.consoleView = consoleView
    }

    func startGame() {
        consoleView.display("Добро пожаловать в игру 'Кристаллы и Драконы'!")
        consoleView.display("Ваша цель: найти ключ, открыть сундук и получить священный Грааль.")
        
        var mazeSizeInput: String
        var size: Int?
        repeat {
            consoleView.display("Введите размер лабиринта (например, 5 для лабиринта 5x5):")
            mazeSizeInput = consoleView.readCmd()
            size = Int(mazeSizeInput)
            if size == nil || size! <= 1 {
                consoleView.display("Некорректный размер. Пожалуйста, введите число больше 1.")
            }
        } while size == nil || size! <= 1
        
        let mazeWidth = size!
        let mazeHeight = size!
        let dynamicMazeGenerator = MazeGenerator(width: mazeWidth, height: mazeHeight)
        guard let (maze, player, _) = dynamicMazeGenerator.generate() else {
            consoleView.display("Не удалось сгенерировать лабиринт. Пожалуйста, попробуйте снова, возможно, с другим размером.")
            return
        }
        
        self.game = Game(player: player, maze: maze)
        runGameLoop()
    }

    private func runGameLoop() {
        guard let game = self.game else { return }

        while !game.gameOver {
            displayCurrentRoom()
            game.player.showInventory()
            consoleView.display("Осталось шагов: \(game.player.playersteps)")
            
            let command = consoleView.readCmd().lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            processCommand(command)
            
            game.checkLoss()
        }

        consoleView.display("Игра завершена.")
        if game.gameWin {
            consoleView.display("Поздравляем с победой!")
        } else {
            consoleView.display("К сожалению, вы проиграли.")
        }
    }

    private func displayCurrentRoom() {
        guard let game = self.game,
              let current = game.maze.room(at: game.player.currentroomCoordinates) else {
            consoleView.display("Ошибка: Не удалось найти текущую комнату.")
            return
        }
        game.drawRoom()
        if(game.checkDarkRoom()){
            consoleView.display("Can’t see anything in this dark place!")
        }
        consoleView.display(current.description())
    }

    private func processCommand(_ command: String) {
        guard let game = self.game else { return }

        let parts = command.split(separator: " ").map(String.init)
        
        if parts.isEmpty {
            consoleView.display("Команда не распознана.")
            return
        }

        switch parts[0] {
        case "n":
            if game.tryMove(direction: .north) {
                consoleView.display("Вы двинулись на север.")
            } else {
                consoleView.display("Вы не можете двигаться на север.")
            }
        case "s":
            if game.tryMove(direction: .south) {
                consoleView.display("Вы двинулись на юг.")
            } else {
                consoleView.display("Вы не можете двигаться на юг.")
            }
        case "w":
            if game.tryMove(direction: .west) {
                consoleView.display("Вы двинулись на запад.")
            } else {
                consoleView.display("Вы не можете двигаться на запад.")
            }
        case "e":
            if game.tryMove(direction: .east) {
                consoleView.display("Вы двинулись на восток.")
            } else {
                consoleView.display("Вы не можете двигаться на восток.")
            }
        case "get":
            guard parts.count > 1 else {
                consoleView.display("Что вы хотите взять? (Используйте: get [предмет])")
                return
            }
            let item = parts[1]
            if !game.tryGetItem(item: item) {
                consoleView.display("Предмет '\(item)' не найден в комнате, или его нельзя взять.")
            }
        case "drop":
            guard parts.count > 1 else {
                consoleView.display("Что вы хотите выбросить? (Используйте: drop [предмет])")
                return
            }
            let item = parts[1]
            if !game.tryDropItem(item: item) {
                consoleView.display("Предмет '\(item)' не найден в вашем инвентаре.")
            }
        case "open":
            guard parts.count > 1 && parts[1] == "chest" else {
                consoleView.display("Что вы хотите открыть? (Используйте: open chest)")
                return
            }
            _ = game.openChest()
        default:
            consoleView.display("Неизвестная команда. Пожалуйста, используйте N, S, W, E, get [item], drop [item], open chest.")
        }
    }
}
