import Foundation
import SQLite

/**
Takes the contents of a FieldDataMap and stores them in an in-memory SQLIte database
 */
class FieldDataSql {
    let TABLE = "LOG"
    var db:Connection
    var log:Table

    init(data:FieldDataMap) throws {
        self.db = try Connection(":memory")
        var stringCols:[String:Expression<String?>] = [:]
        var intCols:[String:Expression<Int64?>] = [:]

        // create table with all known columns
        self.log = Table(TABLE)

        try self.db.run(self.log.drop(ifExists: true))

        try self.db.run(self.log.create { t in
            for it in data.fields {
                let areAllValuesIntegers=it.value
                if areAllValuesIntegers {
                    let col = Expression<Int64?>(it.key)
                    t.column(col)
                    intCols[it.key] = col
                } else {
                    let col = Expression<String?>(it.key)
                    t.column(col)
                    stringCols[it.key] = col
                }
            }
        })

        // add data to table
        for row:[String:String] in data.data {
            var setters:[Setter] = []
            for (key,val) in row {
                let isInteger = data.fields[key]!
                if isInteger {
                    let col = intCols[key]!
                    let setter = col <- Int64(val)
                    setters.append(setter)
                } else {
                    let col = stringCols[key]!
                    let setter = col <- val
                    setters.append(setter)
                }
            }
            let insert = self.log.insert(setters)
            try self.db.run(insert)
        }

    }
}
