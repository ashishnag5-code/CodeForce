package DesignPatterns;

public class Main {


    public static void main(String[] args) throws Exception {

       Student st = Student.builder()
                    .age(20)
                    .name("Ashish")
                    .universityName("VIT")
               .gradYear(2025)
               .build();


       /*Goal -
1. Create student object only after validation
2. Make the readability for object creation code better
3. Immutable object - Means you cannot set an student object directly without calling builder class and in student
class we can have only get methods and Builder class we have the set methods and validations
*/
    /*Steps -
1. Builder class -> Static Class inside Student class, and contains exact same attributes as Student class
2. Create setter method in Builder class -> Setter methods return the builder object
3. validate method in builder class -> collection of all validation logic
4. build method inside builder class ->
        call validation -> call Student copy constructor to create Student object and return
5. Builder method inside Student class which returns builder object*/

    }
}
