import Foundation

/**
 Generates the demo log file used in examples.
 */
class DemoCommand : ScriptCommand {
    var callback : ScriptCallback
    var logDate = Date()
    var linesAdded = 0

    init(callback: ScriptCallback) {
        self.callback = callback
    }

    func validate() -> Bool {
        true
    }

    func changesData() -> Bool {
        true
    }


    enum State {
        case READY
        case RACING
        case DONE
        case CRASHED
    }
    
    func run(logLines: inout [LogLine], runState: inout RunState) -> Bool {
        self.callback.scriptUpdate(text: "Generating demo data")
        
        let numCars = 10
        let numLaps = 5
        var cars = Array(1...numCars)
        var state : [Int:State] = [:]
        var lap : [Int:Int] = [:]
        
        for car in cars {
            state[car] = State.READY
        }
        
        while cars.count > 0 {
            let car = cars.randomElement()!
            
            if( state[car] == State.READY) {
                self.log(text: "car \(car) STARTED", logLines: &logLines)
                state[car] = State.RACING
                lap[car] = 1
            } else if (Int.random(in: 1...100) < 10) {
                self.log(text: "car \(car) CRASHED", logLines: &logLines)
                cars.removeAll(where: {$0 == car})
                state[car] = State.CRASHED
            } else if ( lap[car] == numLaps ) {
                self.log(text: "car \(car) FINISHED", logLines: &logLines)
                cars.removeAll(where: {$0 == car})
                state[car] = State.DONE
            } else {
                lap[car] = lap[car]! + 1
                self.log(text: "car \(car) LAP \(lap[car]!)", logLines: &logLines)
            }
        }
        
        self.callback.scriptUpdate(text: "... generated \(self.linesAdded) log lines")
        return true
    }
    
    func log(text : String, logLines: inout [LogLine]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: self.logDate)
        
        logLines.append( LogLine(text: "[\(dateString)] \(text)", lineNumber: logLines.count) )
        
        let seconds = Int.random(in: 30...90)
        self.logDate = Calendar.current.date(byAdding: .second, value: seconds, to: logDate)!
        
        self.linesAdded = self.linesAdded + 1
    }
    
}
