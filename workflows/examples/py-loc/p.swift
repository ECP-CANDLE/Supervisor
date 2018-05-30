
import io;
import python;
import location;

L0 = locationFromRank(0);
L1 = locationFromRank(1);
  
@location=L0 python_persist("L = []");
@location=L1 python_persist("L = []");
string D[]; 
foreach j in [0:9] { 
  L = locationFromRank(j%%2);
  D[j] = @location=L python_persist("L.append(repr(2+%i)) " % j);
}

wait deep (D) {
  @location=L0 python_persist("print(str(L))");
  @location=L1 python_persist("print(str(L))");
}
