public class Demo {

    private static final String TEST_CONSTANT = 'TESTING';
    private static String testStatic = 'TESTING';
    private String testInstance = 'TESTING';

	public String a;

    public static boolean isSandbox{
        get{
            if(isSandbox == null){
                isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        private set;
    }

    public Demo(String a){
        this.a = a;
    }

    public Demo(){
        this.a = a;
    }

    public static void foo(String b){
        String s = 'hello ';
        System.debug(s + b);
    }

    public Integer fooBar(String b){
        System.debug(b);
        return 3;
    }
}
