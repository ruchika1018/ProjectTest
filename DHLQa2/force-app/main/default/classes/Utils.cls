public class Utils {

    public static String getLoggedInUserName() {
        return UserInfo.getName();
    }
    
    public static String getLoggedId() {
        return UserInfo.getUserId();
    }
}