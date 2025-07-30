# Nim translation of the C++ MoogLadder class in moogladder.h
# from https://github.com/DaanKS/OpenLadderFilter
# Original C++ implementation by Daan & Mila of Triceratops
# Based on Välimäki & Huovilainen (2006)
# Translated to Nim by Christopher Arndt with help from GitHub Copilot/GPT 4.1

import math


type
  LadderCoefficients* = object
    A*, B*, C*, D*, E*: float64

  MoogComponent = object
    a*: float64 = 1.0 / 1.3
    b*: float64 = 0.3 / 1.3
    g*: float64 = 0.0
    x1*: float64 = 0.0
    y1*: float64 = 0.0

  MoogLadder* = object
    currentCoefficients*: LadderCoefficients
    components*: array[4, MoogComponent]
    sampleRate*: float64 = 44_100.0
    omega*: float64 = 0.0
    omegaFactor: float64 = 0.0
    currentResonance*: float64 = 0.0
    res*: float64 = 0.0
    pathE*: float64 = 0.0


# MoogComponent procs
proc calculateG(self: var MoogComponent, omega: float64) =
  self.g = (0.9892 * omega) - (0.4342 * pow(omega, 2.0)) +
           (0.1381 * pow(omega, 3.0)) - (0.0202 * pow(omega, 4.0))

proc feedforward(self: var MoogComponent, input: float64): float64 =
  result = self.a * input + self.b * self.x1
  self.x1 = input

proc feedback(self: var MoogComponent, input: float64): float64 =
  self.y1 = self.g * (input - self.y1) + self.y1
  return self.y1

proc process(self: var MoogComponent, input: float64): float64 =
  self.feedback(self.feedforward(input))


# MoogLadder procs
proc setSampleRate*(self: var MoogLadder, sampleRate: float64) =
  self.sampleRate = sampleRate
  self.omegaFactor = 2.0 * math.PI / sampleRate

proc initMoogLadder*(sampleRate: float64 = 44_100.0): MoogLadder =
  result = default(MoogLadder)
  result.setSampleRate(sampleRate)

  for i in 0..result.components.high:
    result.components[i] = default(MoogComponent)

proc setCoefficients*(self: var MoogLadder, coeffs: LadderCoefficients) =
  self.currentCoefficients = coeffs

proc setResonance*(self: var MoogLadder, resonance: float64) =
  # Expects values between 0 and 1
  self.res = resonance
  self.currentResonance = resonance * (1.0029 + (0.0526 * self.omega) -
    (0.0926 * pow(self.omega, 2.0)) + (0.0218 * pow(self.omega, 3.0)))

proc calculateOmega(self: var MoogLadder, frequency: float64) =
  self.omega = self.omegaFactor * frequency
  setResonance(self, self.res)

proc setCutoff*(self: var MoogLadder, frequency: float64) =
  self.calculateOmega(frequency)
  for i in 0..self.components.high:
    self.components[i].calculateG(self.omega)

proc process*(self: var MoogLadder, input: float64): float64 =
  let cc = self.currentCoefficients
  let feed = 4.0 * self.currentResonance * (self.pathE - tanh(input * 0.5))
  let pathA = input - feed
  let pathB = self.components[0].process(pathA)
  let pathC = self.components[1].process(pathB)
  let pathD = self.components[2].process(pathC)
  self.pathE = self.components[3].process(pathD)
  (pathA * cc.A) + (pathB * cc.B) + (pathC * cc.C) + (pathD * cc.D) + (self.pathE * cc.E)


# Coefficient factory procs
proc makeLoPass12*(): LadderCoefficients =
  LadderCoefficients(A: 0, B: 0, C: 1, D: 0, E: 0)

proc makeLoPass24*(): LadderCoefficients =
  LadderCoefficients(A: 0, B: 0, C: 0, D: 0, E: 1)

proc makeBandPass12*(): LadderCoefficients =
  LadderCoefficients(A: 0, B: 2, C: -2, D: 0, E: 0)

proc makeBandPass24*(): LadderCoefficients =
  LadderCoefficients(A: 0, B: 0, C: 4, D: -8, E: 4)

proc makeHiPass12*(): LadderCoefficients =
  LadderCoefficients(A: 1, B: -2, C: 1, D: 0, E: 0)

proc makeHiPass24*(): LadderCoefficients =
  LadderCoefficients(A: 1, B: -4, C: 6, D: -4, E: 1)
