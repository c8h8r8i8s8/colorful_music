import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.signals.*;
 
Minim minim;
AudioInput in;
AudioOutput out;
SineWave sine;
FFT fft;
FFT fftLin;
FFT fftLog;

float height3;
float height23;

void setup()
{
  size(512, 512, P3D);
 
  minim = new Minim(this);
  minim.debugOn();
 
  // get a line in from Minim, default bit depth is 16
  in = minim.getLineIn(Minim.MONO, 512);
  //out = minim.getLineOut(Minim.STEREO, 2048);
  
  //out.addSignal(in.mix);
  
  fft = new FFT(in.bufferSize(), in.sampleRate());
    
  fftLin = new FFT(in.bufferSize(), in.sampleRate());
  
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin.linAverages(30);
  
  fftLog = new FFT(in.bufferSize(), in.sampleRate());
  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages(220, 3);
  rectMode(CORNERS);
}
 
void draw()
{
  background(0);
  stroke(255);
  
  fft.forward(in.mix);
  
  //for(int i = 0; i < fft.specSize(); i++)
  //{
    // draw the line for frequency band i, scaling it by 4 so we can see it a bit better
  //  line(i, height, i, height - fft.getBand(i)*170);
  //}
  fill(255);
  
  float maxVal = 50;
  
  // draw the waveforms
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    if (in.mix.get(i)*300 > maxVal){
      maxVal = in.mix.get(i)*300;
    }
  }
  
  // draw the logarithmic averages
  
  int interval = int(width/3);
  fftLog.forward(in.mix);
  
  float red = fftAverage(0, interval) * 10;
  float green = fftAverage(interval, interval*2) * 10;
  float blue = fftAverage(interval*2, interval*3) * 10;

  fill(red, green, blue);
  ellipse(width / 2, height / 2, 50+maxVal, 50+maxVal);
}
 
float fftAverage(int start, int end){
  int w = int(width/fftLog.avgSize()); //width of rectangle 
  
  float sum = 0;
  float count = 0;
  
  for(int i = 0; i < fftLog.avgSize(); i++){
    if (i*w >= start && i*w <= end){
      sum += fftLog.getAvg(i);
      count++;
    }
    
    if ( i*w > end ) break;
  }
  
  if (count > 0){
    return sum / count;
  }
  
  return 0;
}
 
void stop()
{
  // always close Minim audio classes when you are done with them
  in.close();
  //out.close();
  minim.stop();
 
  super.stop();
}
