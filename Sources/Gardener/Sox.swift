//
//  Sox.swift
//
//
//  Created by Dr. Brandon Wiley on 6/15/24.
//

#if os(iOS) || os(watchOS) || os(tvOS)
#else

import Foundation
import Logging

import TransmissionAsync

public struct SoxConfig
{
    public let globalOptions: [SoxGlobalOption]
    public let inputOptions: [SoxFormatOption]
    public let inputFile: SoxFile
    public let outputOptions: [SoxFormatOption]
    public let outputFile: SoxFile
    public let effect: SoxEffect?

    public init(globalOptions: [SoxGlobalOption], inputOptions: [SoxFormatOption], inputFile: SoxFile, outputOptions: [SoxFormatOption], outputFile: SoxFile, effect: SoxEffect? = nil)
    {
        self.globalOptions = globalOptions
        self.inputOptions = inputOptions
        self.inputFile = inputFile
        self.outputOptions = outputOptions
        self.outputFile = outputFile
        self.effect = effect
    }

    public var args: [String]
    {
        let globalArgs = globalOptions.flatMap { $0.args }
        let inputArgs = inputOptions.flatMap { $0.args }
        let inputFileArgs = inputFile.args
        let outputArgs = outputOptions.flatMap { $0.args }
        let outputFileArgs = outputFile.args

        let effectArgs: [String]
        if let effect
        {
            effectArgs = effect.args
        }
        else
        {
            effectArgs = []
        }

        return globalArgs + inputArgs + inputFileArgs + outputArgs + outputFileArgs + effectArgs
    }
}

public enum SoxFile
{
    case pipe
    case defaultDevice
    case null
    case soxPipe
    case filename(String)

    public var args: [String]
    {
        switch self
        {
            case .pipe:
                return ["-"]

            case .defaultDevice:
                return ["-d"]

            case .null:
                return ["-n"]

            case .soxPipe:
                return ["-p"]

            case .filename(let filename):
                return [filename]
        }
    }
}

public enum SoxGlobalOption
{
    case buffer(Int)
    case clobber(Bool)
    case combine(SoxCombineStyle)
    case noDither
    case minDFT(Int)
    case effectsFile(String)
    case clippingGuard
    case info
    case inputBuffer(Int)
    case normalize
    case playRate(Int)
    case plot(SoxPlotMethod)
    case progress(Bool)
    case replayGain(SoxReplayGainStyle)
    case defaultRandomNumbers
    case singledThreaded
    case tempDirectory(String)

    public var args: [String]
    {
        switch self
        {
            case .buffer(let bytes):
                return ["--buffer", "\(bytes)"]

            case .clobber(let value):
                if value
                {
                    return ["--clobber"]
                }
                else
                {
                    return ["--no-clobber"]
                }

            case .combine(let style):
                return ["--combine", style.rawValue]

            case .noDither:
                return ["--no-dither"]

            case .minDFT(let num):
                return ["--dft-min", "\(num)"]

            case .effectsFile(let filename):
                return ["--effects-file", filename]

            case .clippingGuard:
                return ["--guard"]

            case .info:
                return ["--info"]

            case .inputBuffer(let bytes):
                return ["--input-buffer", "\(bytes)"]

            case .normalize:
                return ["--norm"]

            case .playRate(let arg):
                return ["--play-rate-arg", "\(arg)"]

            case .plot(let method):
                return ["--plot", method.rawValue]

            case .progress(let value):
                if value
                {
                    return ["--show-progress"]
                }
                else
                {
                    return ["--no-show-progress"]
                }

            case .replayGain(let style):
                return ["--replay-gain", style.rawValue]

            case .defaultRandomNumbers:
                return ["-R"]

            case .singledThreaded:
                return ["--single-threaded"]

            case .tempDirectory(let directory):
                return ["--temp", directory]
        }
    }
}

public enum SoxFormatOption
{
    case volume(Float)
    case ignoreLength
    case type(SoxFileType)
    case encoding(SoxEncodingType)
    case bits(Int)
    case reverseNibbles
    case reverseBits
    case endian(SoxEndianness)
    case channels(Int)
    case rate(Int)
    case compression(Float)
    case addComment(String)
    case comment(String)
    case commentFile(String)
    case noGlob

    public var args: [String]
    {
        switch self
        {
            case .volume(let factor):
                return ["--volume", "\(factor)"]

            case .ignoreLength:
                return ["--ignore-length"]

            case .type(let type):
                return ["--type", type.rawValue]

            case .encoding(let type):
                return ["--encoding", type.rawValue]

            case .bits(let bits):
                return ["--bits", "\(bits)"]

            case .reverseNibbles:
                return ["--reverse-nibbles"]

            case .reverseBits:
                return ["--reverse-bits"]

            case .endian(let endianness):
                return ["--endian", endianness.rawValue]

            case .channels(let channels):
                return ["--channels", "\(channels)"]

            case .rate(let rate):
                return ["--rate", "\(rate)"]

            case .compression(let factor):
                return ["--compression", "\(factor)"]

            case .addComment(let text):
                return ["--add-comment", text]

            case .comment(let text):
                return ["--comment", text]

            case .commentFile(let filename):
                return ["--comment-file", filename]

            case .noGlob:
                return ["--no-glob"]
        }
    }
}

public enum SoxCombineStyle: String
{
    case concatenate
    case sequence
    case mix
    case merge
    case mixPower = "mix-power"
    case multiply
}

public enum SoxPlotMethod: String
{
    case gnuplot
    case octave
}

public enum SoxReplayGainStyle: String
{
    case track
    case album
    case off
}

public enum SoxEncodingType: String
{
    case signedInteger = "signed-integer"
    case unsignedInteger = "unsigned-integer"
    case floatingPoint = "floating-point"
    case muLaw = "mu-law"
    case aLaw = "a-law"
    case imaAdpcm = "ima-adpcm"
    case msAdpcm = "ms-adpcm"
    case gsmFullRate = "gsm-full-rate"
}

public enum SoxEndianness: String
{
    case big
    case little
    case swap
}

public enum SoxFileType: String
{
    case eightsvx = "8svx"
    case aif
    case aifc
    case aiff
    case aiffc
    case al
    case amb
    case au
    case avr
    case caf
    case cdda
    case cdr
    case cvs
    case cvsd
    case cvu
    case dat
    case dvms
    case f32
    case f4
    case f64
    case f8
    case fap
    case flac
    case fssd
    case gsm
    case gsrt
    case hcom
    case htk
    case ima
    case ircam
    case la
    case lpc
    case lpc10
    case lu
    case mat
    case mat4
    case mat5
    case maud
    case mp2
    case mp3
    case nist
    case ogg
    case opus
    case paf
    case prc
    case pvf
    case raw
    case s1
    case s16
    case s2
    case s24
    case s3
    case s32
    case s4
    case s8
    case sb
    case sd2
    case sds
    case sf
    case sl
    case sln
    case smp
    case snd
    case sndfile
    case sndr
    case sndt
    case sou
    case sox
    case sph
    case sw
    case txw
    case u1
    case u16
    case u2
    case u24
    case u3
    case u32
    case u4
    case u8
    case ub
    case ul
    case uw
    case vms
    case voc
    case vorbis
    case vox
    case w64
    case wav
    case wavpcm
    case wve
    case xa
    case xi
}

public enum SoxEffect
{
    case allpass(SoxAllpassConfig)
    case band
    case bandpass
    case bandreject
    case bass
    case bend
    case biquad
    case chorus
    case channels
    case compand
    case contrast
    case dcshift
    case deemph
    case delay
    case dither
    case divide
    case downsample
    case earwax
    case echo
    case echos
    case equalizer
    case fade
    case fir
    case firfit
    case flanger
    case gain
    case highpass
    case hilbert
    case input
    case loudness
    case lowpass
    case mcompand
    case noiseprof
    case noisered
    case norm
    case opps
    case output
    case overdrive
    case pad
    case phaser
    case pitch
    case rate
    case remix
    case repeated
    case reverb
    case reverse
    case riaa
    case silence
    case sinc
    case spectrogram
    case speed
    case splice
    case stat
    case stats
    case stretch
    case swap
    case synth
    case tempo
    case treble
    case tremolo
    case trim
    case upsample
    case vad
    case vol

    public var args: [String]
    {
        switch self
        {
            case .allpass(let config):
                return ["allpass", "\(config.frequency)", "\(config.width)"]

            //FIXME: add other effects

            default:
                return []
        }
    }
}

public struct SoxAllpassConfig
{
    public let frequency: Float
    public let width: Float

    public init(frequency: Float, width: Float)
    {
        self.frequency = frequency
        self.width = width
    }
}

public class Sox
{
    var command: Command

    public init()
    {
        command = Command()
    }

    public func cd(_ path: String) -> Bool
    {
        return command.cd(path)
    }

    public func run(_ config: SoxConfig) -> (Int32, Data, Data)?
    {
        command.run("sox", config.args)
    }

    public func openForReading(_ config: SoxConfig, _ logger: Logger) throws -> AsyncConnection
    {
        print("sox \(config.args)")
        guard let pipes = command.runWithPipes("sox", config.args) else
        {
            throw SoxError.soxFailure
        }

        return TransmissionSox(pipes, SoxReadWrite.read, logger: logger)
    }

    public func openForWriting(_ config: SoxConfig, _ logger: Logger) throws -> AsyncConnection
    {
        guard let pipes = command.runWithPipes("sox", config.args) else
        {
            throw SoxError.soxFailure
        }

        return TransmissionSox(pipes, SoxReadWrite.write, logger: logger)
    }
}

public enum SoxReadWrite
{
    case read
    case write
}

public class TransmissionSox: AsyncConnection
{
    let pipes: CancellablePipes
    let readWrite: SoxReadWrite
    let connection: AsyncConnection

    var isOpen: Bool

    public init(_ pipes: CancellablePipes, _ readWrite: SoxReadWrite, logger: Logger)
    {
        self.pipes = pipes
        self.readWrite = readWrite
        self.isOpen = true

        switch readWrite
        {
            case .read:
                self.connection = AsyncReadOnlyFileHandleConnection(readFile: pipes.stdoutHandle, logger)

            case .write:
                self.connection = AsyncWriteOnlyFileHandleConnection(writeFile: pipes.stdinHandle, logger)
        }
    }

    public func read() async throws -> Data
    {
        guard self.isOpen else
        {
            throw SoxError.closed
        }

        return try await self.connection.read()
    }
    
    public func readSize(_ size: Int) async throws -> Data
    {
        guard self.isOpen else
        {
            throw SoxError.closed
        }

        return try await self.connection.readSize(size)
    }
    
    public func readMaxSize(_ maxSize: Int) async throws -> Data
    {
        guard self.isOpen else
        {
            throw SoxError.closed
        }

        return try await self.connection.readMaxSize(maxSize)
    }
    
    public func readMinMaxSize(_ minSize: Int, _ maxSize: Int) async throws -> Data
    {
        guard self.isOpen else
        {
            throw SoxError.closed
        }

        return try await self.connection.readMinMaxSize(minSize, maxSize)
    }
    
    public func readWithLengthPrefix(prefixSizeInBits: Int) async throws -> Data
    {
        guard self.isOpen else
        {
            throw SoxError.closed
        }

        return try await readWithLengthPrefix(prefixSizeInBits: prefixSizeInBits)
    }
    
    public func readWithLengthPrefixNonblocking(prefixSizeInBits: Int) async throws -> Data
    {
        guard self.isOpen else
        {
            throw SoxError.closed
        }

        return try await readWithLengthPrefixNonblocking(prefixSizeInBits: prefixSizeInBits)
    }
    
    public func writeString(string: String) async throws
    {        
        guard self.isOpen else
        {
            throw SoxError.closed
        }

        try await self.connection.writeString(string: string)
    }
    
    public func write(_ data: Data) async throws
    {
        guard self.isOpen else
        {
            throw SoxError.closed
        }

        try await self.connection.write(data)
    }
    
    public func writeWithLengthPrefix(_ data: Data, _ prefixSizeInBits: Int) async throws
    {
        guard self.isOpen else
        {
            throw SoxError.closed
        }

        try await self.connection.writeWithLengthPrefix(data, prefixSizeInBits)
    }
    
    public func close() async throws
    {
        self.isOpen = false

        let _ = self.pipes.cancel()
    }
}

public enum SoxError: Error
{
    case closed
    case empty
    case soxFailure
    case unsupported
}

#endif
