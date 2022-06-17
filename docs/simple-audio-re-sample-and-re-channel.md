---
title: Simple audio re-channel and re-sample
description: A quick example of how to re-sample and re-channel audio in C
tags: audio, sample, sample rate, re-sample, re-channel, c
date: 06/25/2020
---

### Re-Sample
I was recently writing a VOIP program in C using OPUS and I found the need to resample audio. First of all, a little bit about why you would need to resample audio. If you look at the audio settings in your computer, you will find that your microphone has a sample rate and your speakers have a sample rate, and for most devices, you can change the sample rate. Well something you may want to do is re-sample your microphone to be a higher sample rate for example. In my case I had a microphone that was 44.1KHz and speakers that were set to 48KHz (and for testing I set my speakers to 96Khz). So I was in need of up-sampling the data captured by my microphone to match the sample rate of my speakers. Though my actual function is a bit different then the one below (accounting for channels and waveform types other than just `float`), it is the gist of what I needed to do (slightly altered for easier readability). Also the idea behind matching your incoming sample rate (be it from a microphone or over the internet) is so that it plays smoothly and clearly through your speakers without distortion or pitch problems.
```c
int32_t resample(float* out, const float* in, int32_t speakerSampleRate,
	int32_t micSampleRate, size_t inSize, int channels)
{
	// We are assuming that the mic and speaker channels match,
	// otherwise we will need to re-channel the input audio data (in)
	// before we call the resample func (see below sample)
	// micSampleRate = 44100
	// speakerSampleRate = 48000
	
	// Get our current ratio to be able to interpolate
	const double ratio = (double)speakerSampleRate / micSampleRate;
	const int32_t resampleTotal = (int32_t)floor(inSize * ratio);
	const size_t len = resampleTotal / sizeof(float);
	
	for (size_t i = 0, offset = 0; i < len; i += channels)
	{
		size_t idx = (size_t)(i / ratio) & (SIZE_MAX - 1);
		if (idx + offset != i && idx + 2 < len)
		{
			// We are in-between samples, so fill it in
			out[i] = (out[i - 2] + in[idx + 2]) / 2.0F;
			out[i + 1] = (out[i - 1] + in[idx + 3]) / 2.0F;
			offset += channels;
		}
		else
		{
			// Copy the sample directly over to the out
			out[i] = in[idx];
			out[i + 1] = in[idx + 1];
		}
	}
	return resampleTotal;
}
```

You should also play around with not matching the sample rate exactly; you'll be in for a lot of interesting effects, just don't buffer overflow!

### Re-Channel
Sometimes the incoming audio either doesn't have enough channels or has too many channels. When we are dealing with speakers that say have 2 channels but the incoming audio only has 1 channel, we need to turn that 1 channel into 2. On the other side, if the incoming audio has 8 channels and we only have 2 channels for our speakers, we need to re-channel the incoming audio down to just the 2 channels. The following function is a way of converting from one set of channels to another.
```c
void rechannel(float* out, float* in,
	int16_t outChannels, int16_t inChannels, size_t sampleSize)
{
	size_t idx = 0;
	if (outChannels == 1 && inChannels > 1)
	{
		// Just down channel the incoming sterio channels to mono
		for (size_t i = 0; i < sampleSize; i += inChannels)
			out[idx++] = (in[i] * 0.5f) + (in[i + 1] + 0.5f);
	}
	else if (outChannels > inChannels)
	{
		for (size_t i = 0; i < sampleSize; i += inChannels)
		{
			float val = in[i] * 0.5F;
			// If the input is sterio, get the average value sum
			if (inChannels > 1)
				val += in[i + 1] * 0.5F;
			// Copy the average value into the remaining channels
			for (int16_t j = 0; j < outChannels; ++j)
				out[idx++] = val;
		}
	}
	else
	{
		memcpy_s(out, sampleSize * sizeof(float),
			in, sampleSize * sizeof(float));
	}
}
```
