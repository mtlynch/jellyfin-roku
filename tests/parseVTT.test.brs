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

        m.it("handles malformed VTT with timestamp at end of input gracefully", sub()
            ' This test exposes a bug where parseVTT crashes when a timestamp line
            ' appears at the end of input without a following line. The function
            ' tries to access lines[i + 1] which is out of bounds, causing a crash.
            ' The function should gracefully handle this by skipping the malformed entry.
            vttLines = [
                "WEBVTT",
                "",
                "00:00:01.000 --> 00:00:03.500",
                "First caption",
                "",
                "00:00:05.000"
            ]
            ' Join with newline and add the timestamp marker to make it look like a timestamp
            vttInput = vttLines.join(chr(10))
            ' Manually add the timestamp marker that isTime() checks for
            vttInput = vttInput + chr(31)

            result = vtt_parseVTT(vttInput)

            ' Should return valid result with only the first caption
            m.assert.isValid(result, "parseVTT should return a valid result")
            m.assert.equal(result.count(), 1, "should have one valid caption entry, skipping malformed one")

            entry = result[0]
            m.assert.equal(entry.start, 1000, "start time should be 1000ms")
            m.assert.equal(entry.end, 3500, "end time should be 3500ms")
            m.assert.deepEquals(entry.text, ["First caption"], "text should match")
        end sub)

        m.it("handles malformed VTT with style missing colon gracefully", sub()
            ' This test exposes a bug in extractStyles where it crashes when
            ' a style attribute doesn't contain a colon. The function should
            ' gracefully skip malformed style attributes.
            vttLines = [
                "WEBVTT",
                "",
                "00:00:01.000 --> 00:00:03.500 align position:50%",
                "Caption with malformed style",
                ""
            ]
            vttInput = vttLines.join(chr(10))

            result = vtt_parseVTT(vttInput)

            ' Should return valid result, skipping the malformed style
            m.assert.isValid(result, "parseVTT should return a valid result")
            m.assert.equal(result.count(), 1, "should have one caption entry")

            entry = result[0]
            m.assert.equal(entry.start, 1000, "start time should be 1000ms")
            m.assert.equal(entry.end, 3500, "end time should be 3500ms")
            m.assert.deepEquals(entry.text, ["Caption with malformed style"], "text should match")
            ' Should have only the valid style, skipping "align" which has no colon
            m.assert.equal(entry.styles.count(), 1, "should have one valid style")
            m.assert.equal(entry.styles.position, "50%", "position style should be parsed")
        end sub)
    end sub)
end function
