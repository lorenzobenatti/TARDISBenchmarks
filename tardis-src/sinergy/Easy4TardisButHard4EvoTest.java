package sinergy;

import sinergy.*;

public class Easy4TardisButHard4EvoTest{
	
	public void test0(){
		SinergyEasy4TardisButHard4Evo t = new SinergyEasy4TardisButHard4Evo(2, 1);
		
		for (int i=1; i<15; i++) {
			t.setArrayAt(i-1, i);
			}
		t.easy4TardisButHard4Evo();
		
	}
        
	public void test1() {
		SinergyEasy4TardisButHard4Evo t = new SinergyEasy4TardisButHard4Evo(2000000, 100);
		
		for (int i=1; i<15; i++) {
			t.setArrayAt(i-1, i);
			}
		t.easy4TardisButHard4Evo();
	}
	
	public void test2() {
		SinergyEasy4TardisButHard4Evo t = new SinergyEasy4TardisButHard4Evo(2000000, 1);
		
		for (int i=1; i<15; i++) {
			t.setArrayAt(i-1, i);
			}
		t.easy4TardisButHard4Evo();
	}
}
