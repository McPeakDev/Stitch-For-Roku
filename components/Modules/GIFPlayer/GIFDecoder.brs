sub init()
    m.top.functionName = "runDecoder"
    m.gifName = ""
end sub

sub runDecoder()
    m.gifName = CreateObject("roPath", m.top.uri).split().basename
    ' Load the main GIF into memory.
    ' @NOTE: For big GIFs, the bytes of the GIF should be read as needed using:
    ' `ReadFile(path as String, start_pos as Integer, length as Integer) As Boolean`.
    gifBytes = CreateObject("roByteArray")
    ' ? "gifName: "; m.gifName
    ' ? "gifUri: "; m.top.uri
    gifBytes.readFile(m.top.uri)

    ' Read the header block bytes. The header block always has a length of 6 bytes.
    ' Ensure the file is a supported gif file.
    ' ? "header Bytes"
    headerBytes = subByteArrayFrom(gifBytes, 0, 6)
    header = headerBytes.toAsciiString()
    if header <> "GIF89a"
        ' Handle unsupported file errors.
        ? "Unsupported File Type"
        return
    end if

    ' Get the logical screen descriptor.
    ' ? "screen descriptor bytes"
    logicalScreenDescriptorBytes = subByteArrayFrom(gifBytes, 6, 7)

    ' Get the global color table bytes (if available)
    globalColorTableBytes = invalid
    globalColorTableSize = colorTableSize(gifBytes, 6, true)
    if globalColorTableSize
        ' The global color table follows the logical screen descriptor
        ' ? "global color table"
        globalColorTableBytes = subByteArrayFrom(gifBytes, 13, globalColorTableSize)
    end if

    ' Concatenate common bytes
    gifFrameCommonBytes = createObject("roByteArray")
    gifFrameCommonBytes.append(headerBytes)
    gifFrameCommonBytes.append(logicalScreenDescriptorBytes)

    ' The trailer byte that will be always appended to each individual GIF.
    trailerByte = createObject("roByteArray")
    trailerByte.FromHexString("3b")

    ' Capture all the frames in the GIF and store them as individual GIFs.
    frames = []
    frameNumber = 0
    durationTracker = []
    totalDuration = 0.0
    byteIndex = 13 + globalColorTableSize
    ' gifFrameData = []
    while byteIndex < gifBytes.count()
        increment = 1

        hexVal = StrI(gifBytes[byteIndex], 16)
        if hexVal = "21" ' Extension block introducer
            extensionLabel = StrI(gifBytes[byteIndex + 1], 16)
            if extensionLabel = "ff" ' Application extension (will be ignored)
                ' Skip the application extension block.
                ' The application extension block has a fixed size of 19
                increment = 19
            else if extensionLabel = "fe" ' Comment extension (will be ignored)
                ' Skip the comment extension block.
                ' The comment extension block ends when a zero-value byte is found.
                commentExtensionLastByteIndex = byteIndex + 2
                while (gifBytes[commentExtensionLastByteIndex] > 0)
                    commentExtensionLastByteIndex += gifBytes[commentExtensionLastByteIndex] + 1
                end while
                increment = commentExtensionLastByteIndex - byteIndex + 1
            else if extensionLabel = "01" ' Plain text extension (will be ignored)
                ' @TODO: skip all the plain text extension bytes
                exit while
            else if extensionLabel = "f9" ' Graphic control extension
                ' The fith byte in the graphic control extension block has the delay time of the next frame.
                ' This value is represented as hundredths (1/100) of a second.
                ' @NOTE: The gif spec refers to the fith and the sixth byte but in all the examples only the fith
                ' value is taken into account, not the sixth.
                delayTime = gifBytes[byteIndex + 4] / 100.0
                totalDuration += delayTime
                durationTracker.push(delayTime)
                ' packedFieldData = decimalTo8Bit(gifBytes[byteIndex + 3])
                ' byteData = {
                '     ExtensionIntroducer: StrI(gifBytes[byteIndex], 16)
                '     GraphicControlLabel: StrI(gifBytes[byteIndex + 1], 16)
                '     BlockSize: StrI(gifBytes[byteIndex + 2], 16)
                '     PackedFields: {
                '         Reserved: packedFieldData.left(3).toint()
                '         DisposalMethod: packedFieldData.mid(3, 3).toint()
                '         UserInputFlag: packedFieldData.mid(6, 1).toint()
                '         TransparentColorFlag: packedFieldData.right(1).toint()
                '     }
                '     DelayTime: StrI(gifBytes[byteIndex + 4], 16)
                '     DelayTimeExt: StrI(gifBytes[byteIndex + 5], 16)
                '     TransparentColorIndex: StrI(gifBytes[byteIndex + 6], 16)
                '     BlockTerminator: StrI(gifBytes[byteIndex + 7], 16)
                ' }
                ' The graphic control extension block has a fixed size of 8
                increment = 8
            else
                ' Handle invalid extension label error.
                exit while
            end if
        else if hexVal = "2c" ' Image descriptor block
            ' Get the local color table size so that we can know where the image data starts
            localColorTableInfoByteIndex = byteIndex + 9 ' The packed field with the local table info is always in the 10th byte.
            localColorTableSize = colorTableSize(gifBytes, byteIndex)

            ' Determine the image descriptor + the image data size
            imageDataByteStartIndex = localColorTableInfoByteIndex + localColorTableSize + 1
            imageDataByteEndIndex = imageDataByteStartIndex + 1
            while (gifBytes[imageDataByteEndIndex] > 0)
                imageDataByteEndIndex += gifBytes[imageDataByteEndIndex] + 1
            end while
            imageDescriptorAndDataSize = imageDataByteEndIndex - byteIndex + 1

            ' Create the new gif file for this frame with the common bytes
            gifFramePath = "tmp:/" + m.gifName + "_" + frameNumber.toStr() + ".gif"
            gifFrameCommonBytes.writeFile(gifFramePath)

            ' Append the global color table only if there's no local color table for this frame
            if localColorTableSize = 0 and globalColorTableBytes <> invalid
                globalColorTableBytes.appendFile(gifFramePath, 0, globalColorTableSize)
            end if

            ' Append the image data of this frame
            gifBytes.appendFile(gifFramePath, byteIndex, imageDescriptorAndDataSize)
            trailerByte.appendFile(gifFramePath, 0, 1)

            ' Save new gif url
            frames.push(gifFramePath)
            frameNumber++
            ' gifFrameData.push(
            '     {
            '         frame: frameNumber
            '         path: gifFramePath
            '         commonBytes: gifFrameCommonBytes
            '         localColorTableSize: localColorTableSize
            '         gifBytes: gifBytes
            '     }
            ' )
            ' Go to the next block of data in the next interation
            increment = imageDataByteEndIndex - byteIndex + 1
            lastFrameGifBytes = gifBytes
        else if hexVal = "3b" ' Trailer (should be the last byte in a gif file)
            exit while
        end if

        byteIndex += increment
    end while

    ' Notify delegate
    fps = totalDuration / frames.count()

    m.top.frames = frames
    m.top.framedelay = durationTracker
    m.top.fps = fps
    m.top.finished = true
    ' m.top.delegate.callFunc("gifDecoderDidFinish", frames, fps)
end sub



' Locates the color table based on the descriptor information and returns its size (if a color table is present).
function colorTableSize(gifBytes as object, descriptorLocation as integer, globalFlag = false as boolean) as integer
    size = 0

    ' For the case of image descriptors the packed field with the table info is always in the 10th byte
    ' and for the case of the logical screen descriptor is always in the 5th byte.
    packedFieldLocation = descriptorLocation + 9
    if globalFlag
        packedFieldLocation = descriptorLocation + 4
    end if
    ' The color table information is meant to be interpret in is binary (8-bit) representation.
    colorTableInfoBits = decimalTo8Bit(gifBytes[packedFieldLocation])

    ' Check if there is a color table by checking the first bit of the color table info bits.
    if colorTableInfoBits.left(1) = "1"
        ' The bits 1...3 represent the number of bits used for each color table entry minus one.
        bitsPerEntry = Val(colorTableInfoBits.right(3), 2) + 1

        ' The number of colors in the table can be calculated as: `2^(bitsPerEntry)`.
        ' Which means that the size of the table would be 3*2^(bitsPerEntry).
        size = 3 * pow(2, bitsPerEntry)
    end if

    return size
end function

' Returns a slice of the given array
function subByteArrayFrom(byteArray as object, location as integer, length as integer) as object
    newArray = CreateObject("roByteArray")
    for i = location to location + length - 1
        newArray.push(byteArray[i])
    end for
    return newArray
end function

' Converts the given decimal to its 8-bit representation
function decimalTo8Bit(decimal as integer) as string
    ' This is crazy. string of 0000000, add the binary string value to the end 00000000000001, then slice right(8) 00000001
    return ("0000000" + StrI(decimal, 2)).right(8)
end function

' Returns a number raised to a given power.
function pow(x as float, y as integer) as float
    if y = 0 then return 1

    temp = pow(x, y / 2)
    if y mod 2 = 0 then return temp * temp
    if y > 0 then return x * temp * temp

    return (temp * temp) / x
end function