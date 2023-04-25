package sinergy;

public class SinergyEasy4TardisButHard4Evo {
	public final int SIZE = 14;
	private int a;
	private int b;
	private int[] array = new int[SIZE];
	
	public SinergyEasy4TardisButHard4Evo(int a, int b) {
		this.a = a;
		this.b = b;
	}
	
	public void setArrayAt(int i, int value) {
		this.array[Math.abs(i) % this.array.length] = value;
	}
	
	public void easy4TardisButHard4Evo() {
		int x = 99;
		if (a > 1000000) {
			x = b;
		}
		if (x == 100) {
			//this branch is hard for EvoSuite
			hard4TardisButEasy4Evo();	
		}
	}

	private void hard4TardisButEasy4Evo() {
		int count = 0;
		for (int i = 0; i < array.length; ++i) {
			if (array[i] != 0) {
				++count;
			}
		}
		if (count > SIZE * 0.5) {
			//this branch is hard for Tardis
			easy4TardisButHard4Evo_bis();
		}
	}

	public void easy4TardisButHard4Evo_bis() {
		int x = 99;
		if (a > 1000000) {
			x = b;
		}
		if (x == 100) {
			//this branch is hard for EvoSuite
			sink();	
		}
	}

	private void sink() {
	}

}
