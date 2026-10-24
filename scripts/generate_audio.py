"""Original synthesized PCM effects; upload these to Roblox before setting asset IDs."""
from pathlib import Path
import math, random, struct, wave
root=Path(__file__).resolve().parents[1]/'assets/audio'
root.mkdir(parents=True,exist_ok=True)
for name,freq,duration in [('impact',95,0.18),('cast',660,0.35),('dodge',210,0.22)]:
 rng=random.Random(123);rate=22050;out=[]
 for i in range(int(rate*duration)):
  t=i/rate;envelope=(1-t/duration)**2
  sample=(math.sin(2*math.pi*(freq*t+freq*t*t))*0.6+rng.uniform(-1,1)*0.4)*envelope*0.45
  out.append(struct.pack('<h',int(sample*32767)))
 with wave.open(str(root/(name+'.wav')),'wb') as f:
  f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(b''.join(out))
print('Três WAV originais gerados; playback no Roblox depende de upload autorizado.')
