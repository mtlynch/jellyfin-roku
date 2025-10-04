function main(args as object) as object
    return roca(args).describe("vtt.parseVTT", sub()
        m.it("parses a simple VTT caption", sub()
            vttLines = [
                "WEBVTT",
                "",
                "00:00:01.000 --> 00:00:03.500",
                "Hello, this is a test caption",
                ""
            ]
            vttInput = vttLines.join(chr(10))

            result = vtt_parseVTT(vttInput)

            m.assert.isValid(result, "parseVTT should return a valid result")
            m.assert.equal(result.count(), 1, "should have one caption entry")

            entry = result[0]
            m.assert.equal(entry.start, 1000, "start time should be 1000ms")
            m.assert.equal(entry.end, 3500, "end time should be 3500ms")
            m.assert.deepEquals(entry.text, ["Hello, this is a test caption"], "text should match")
            m.assert.isValid(entry.id, "entry should have an id")
            m.assert.deepEquals(entry.styles, {}, "styles should be empty object")
        end sub)

        m.it("parses a VTT caption with hours omitted", sub()
            vttLines = [
                "WEBVTT",
                "",
                "00:01.000 --> 00:03.500",
                "This caption leaves out the hours from timestamps",
                ""
            ]
            vttInput = vttLines.join(chr(10))

            result = vtt_parseVTT(vttInput)

            m.assert.isValid(result, "parseVTT should return a valid result")
            m.assert.equal(result.count(), 1, "should have one caption entry")

            entry = result[0]
            m.assert.equal(entry.start, 1000, "start time should be 1000ms")
            m.assert.equal(entry.end, 3500, "end time should be 3500ms")
            m.assert.deepEquals(entry.text, ["This caption leaves out the hours from timestamps"], "text should match")
            m.assert.isValid(entry.id, "entry should have an id")
            m.assert.deepEquals(entry.styles, {}, "styles should be empty object")
        end sub)
    end sub)
end function
