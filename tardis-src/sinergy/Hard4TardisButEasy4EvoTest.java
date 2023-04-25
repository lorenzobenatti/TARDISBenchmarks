package sinergy;

public class Hard4TardisButEasy4EvoTest{
	
	public void test0(){
		SinergyHard4TardisButEasy4Evo t = new SinergyHard4TardisButEasy4Evo(2000000, 100);
		
		for (int i=1; i<15; i++) {
			t.setArrayAt(i-1, i);
			}
		t.hard4TardisButEasy4Evo();
	}
        
	public void test1() {
		SinergyHard4TardisButEasy4Evo t = new SinergyHard4TardisButEasy4Evo(2, 1);
		
		for (int i=1; i<15; i++) {
			t.setArrayAt(i-1, i);
			}
		t.hard4TardisButEasy4Evo();
	}
	
	public void test2() {
		SinergyHard4TardisButEasy4Evo t = new SinergyHard4TardisButEasy4Evo(2000000, 1);
		
		for (int i=1; i<15; i++) {
			t.setArrayAt(i-1, i);
			}
		t.hard4TardisButEasy4Evo();
	}
}
