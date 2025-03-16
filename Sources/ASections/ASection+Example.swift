import AFormula
import AFunction
import AValue

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension [ASection] {
    static func createExample() -> [ASection] {
        // Section 1: Speed Calculation
        var length = ARow.variable(name: "Length", type: .number, unit: .meters)
        length.value = 235
        var time = ARow.variable(name: "Time", type: .number, unit: .seconds)
        time.value = 10
        let speed = ARow.computed(name: "Speed", unit: .metersPerSecond) {
            length.row() / time.row()
        }
        let acceleration = ARow.computed(name: "Acceleration", unit: .metersPerSecondSquared) {
            speed.row() / time.row()
        }
        let speedSection = ASection(name: "Speed Calculation", rows: [length, time, speed, acceleration])

        // Section 2: Distance Calculation
        var point1 = ARow.variable(name: "Point 1", type: .location, unit: nil)
        point1.value = .location(latitude: 40, longitude: 116)
        var point2 = ARow.variable(name: "Point 2", type: .location, unit: nil)
        point2.value = .location(latitude: 41, longitude: 117)
        let distance = ARow.computed(name: "Distance", unit: .meters) {
            .f(.distanceFunction, args: [point1.row(), point2.row()])
        }
        let distanceSection = ASection(name: "Distance Calculation", rows: [point1, point2, distance])

        // Section 3: Conversion
        let lengthTimes2 = ARow.conversion(id: 22, name: "Length*2", unit: .meters) {
            length.row() * 2
        } createConversions: {
            [
                .init(id: length.id, formula: .variable(id: 22) / 2)
            ]
        }
        let lengthTimes4 = ARow.conversion(id: 44, name: "Length*4", unit: .meters) {
            length.row() * 4
        } createConversions: {
            [
                .init(id: lengthTimes2.id, formula: .variable(id: 44) / 2)
            ]
        }

        let conversionSection = ASection(name: "Conversion", rows: [lengthTimes2, lengthTimes4])

        var booleanTest: ARow = .variable(name: "test", type: .boolean, unit: nil)
        booleanTest.value = true
        let booleanComputed: ARow = .computed(name: "test2", unit: nil) {
            .ternary(condition: booleanTest.row(), trueFormula: 5, falseFormula: false)
        }
        let booleanSection = ASection(name: "Booleans", rows: [booleanTest, booleanComputed])

        var date1: ARow = .variable(name: "date1", type: .calendar, unit: nil)
        date1.value = .calendar(.now, timeZone: .current)
        let dateDiff1: ARow = .variable(name: "diff1", type: .dateDifference, unit: nil)
        let date2: ARow = .computed(name: "date+diff1", unit: nil) {
            date1.row() + dateDiff1.row()
        }
        let dateSection = ASection(name: "date", rows: [date1, dateDiff1, date2])

        let time1: ARow = .variable(name: "time1", type: .minutes, unit: nil)
        let time2: ARow = .variable(name: "time2", type: .minutes, unit: nil)
        let time3: ARow = .computed(name: "time1+2", unit: nil) {
            time1.row() + time2.row()
        }
        let date3: ARow = .computed(name: "date1+time3", unit: nil) {
            date1.row() + time3.row()
        }
        let timeSection = ASection(name: "Time", rows: [time1, time2, time3, date3])

        let color1: ARow = .variable(name: "Color1", type: .color, unit: nil)
        let color2: ARow = .variable(name: "Color2", type: .color, unit: nil)
        let color3: ARow = .computed(name: "Color3", unit: nil) {
            color1.row() * color2.row()
        }
        let wind1: ARow = .variable(name: "WindLimit1", type: .groundWind, unit: .knots)
        let vector1: ARow = .variable(name: "Vector1", type: .point, unit: .knots)
        let vector2: ARow = .variable(name: "Vector2", type: .point, unit: .knots)
        let vector3: ARow = .computed(name: "Vector1+2", unit: .knots) {
            vector1.row() + vector2.row()
        }
        let miscSection = ASection(name: "Misc", rows: [color1, color2, color3, wind1, vector1, vector2, vector3])

        // Combine all sections
        let sections = [speedSection, distanceSection, conversionSection, booleanSection, dateSection, timeSection, miscSection]

        return sections
    }
}
