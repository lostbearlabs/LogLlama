import Foundation

/// Generates the demo log file used in examples.
class DemoCommand: ScriptCommand {
  var callback: ScriptCallback
  var logDate = Date()
  var linesAdded = 0
  var text: String? = nil
  var numRaces = 3

  init(callback: ScriptCallback, text: String?) {
    self.callback = callback
    self.text = text
  }

  func validate() -> Bool {
    if text != nil {
      let n = Int(text!)
      if n != nil {
        self.numRaces = n!
      } else {
        self.callback.scriptUpdate(text: "Not an integer: \(self.text!)")
        return false
      }

    }

    return true
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

  func run(logLines: inout LogLineArray, runState: inout RunState) -> Bool {
    self.callback.scriptUpdate(text: "Generating demo data for \(numRaces) races")

    for i in 1...numRaces {
      runRace(raceNum: i, logLines: &logLines, runState: &runState)
    }

    self.callback.scriptUpdate(text: "... generated \(self.linesAdded) log lines")
    return true

  }

  func runRace(raceNum: Int, logLines: inout LogLineArray, runState: inout RunState) {

    let numCars = 10
    let numLaps = 5

    self.log(text: "*** Race \(raceNum) ***", logLines: &logLines)

    var cars = Array(1...numCars)
    var state: [Int: State] = [:]
    var lap: [Int: Int] = [:]

    for car in cars {
      state[car] = State.READY
    }

    while cars.count > 0 {
      let car = cars.randomElement()!

      if state[car] == State.READY {
        self.log(text: "race=\(raceNum), car=\(car), event=STARTED", logLines: &logLines)
        state[car] = State.RACING
        lap[car] = 1
      } else if Int.random(in: 1...100) < 10 {
        self.log(text: "race=\(raceNum), car=\(car), event=CRASHED", logLines: &logLines)
        cars.removeAll(where: { $0 == car })
        state[car] = State.CRASHED
      } else if lap[car] == numLaps {
        self.log(text: "race=\(raceNum), car=\(car), event=FINISHED", logLines: &logLines)
        cars.removeAll(where: { $0 == car })
        state[car] = State.DONE
      } else {
        lap[car] = lap[car]! + 1
        self.log(
          text: "race=\(raceNum), car=\(car), event=LAP, lapNum=\(lap[car]!)", logLines: &logLines)
      }
    }

  }

  func log(text: String, logLines: inout LogLineArray) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = dateFormatter.string(from: self.logDate)

    logLines.append(LogLine(text: "[\(dateString)] \(text)", lineNumber: logLines.count))

    let seconds = Int.random(in: 30...90)
    self.logDate = Calendar.current.date(byAdding: .second, value: seconds, to: logDate)!

    self.linesAdded = self.linesAdded + 1
  }

  func description() -> String {
    return "demo"
  }

}
