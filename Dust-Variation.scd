// Dust - Variation (SuperCollider score)
// Copyright Tony Wallace 2014
// http://tonywallace.com

Server.default = s = Server.local.boot;

(
	SynthDef(\twDustVariation, {

		var intervalCount = 7,
			intervalRatio = 3/2, 
			baseFreq = 110.0,
			baseLevel = 0.02,
			baseDuration = 30.0,
			osc = [];

		// Sub tone:

		osc = osc.add(SinOsc.ar(
			freq: baseFreq / 2.0,
			mul: EnvGen.kr(
				envelope: Env(
					levels: [0.000001, baseLevel, baseLevel, 0.000001],
					times: [baseDuration, baseDuration * (intervalCount * 2), baseDuration],
					curve: \exponential),
				doneAction: 2)
			)
		);

		// Harmonics:
		
		intervalCount.do({

			arg i;

			var oscRatio = intervalRatio**i,
				oscFreq = baseFreq * oscRatio,
				oscLevel = baseLevel / oscRatio,
				rampTime = baseDuration * (i + 1),
				holdTime = baseDuration * ((intervalCount - i) * 2);

			var densityEnv = Env(
				levels: [10.0, 100.0, 100.0, 10.0],
				times: [rampTime, holdTime, rampTime],
				curve: \linear);

			// Grainsin:
			osc = osc.add(GrainSin.ar(
				numChannels: 2, 
				trigger: Dust.kr(
					density: EnvGen.kr(
						envelope: densityEnv,
						doneAction: 2)
					),
				freq: oscFreq,
				pan: Dust.kr(
					density: EnvGen.kr(
						envelope: densityEnv,
						doneAction: 2), 
					mul: 2.0, 
					add: -1.0),
				mul: EnvGen.kr(
					envelope: Env(
						levels: [0.000001, oscLevel, oscLevel, 0.000001],
						times: [rampTime, holdTime, rampTime],
						curve: \exponential),
					doneAction: 2)
				)
			);

		});
		
		Out.ar([0, 1], Mix.ar(osc));

	}).load(s);
)

// Play:
Synth(\twDustVariation);