package DesignPatterns;

public class Student {



    private int gradYear;
    private String name;
    private static int age;
    private double psp;
    private String universityName;
    private String phoneNumber;


    // first we need to make constructor as private
    // Here we will use copy constructor
    public Student(Builder build){
        this.gradYear = build.gradYear;
        this.name = build.name;
        this.age = build.age;
        this.psp = build.psp;
        this.universityName = build.universityName;
        this.phoneNumber = build.phoneNumber;
    }

    // This will return the instance of builder object
    public static Builder builder(){
        return new Builder();
    }

    //getter Properties needs to be added in Outer Class


    public String getName() {
        return name;
    }

    public int getAge() {
        return age;
    }

    public double getPsp() {
        return psp;
    }

    public String getUniversityName() {
        return universityName;
    }

    public int getGradYear() {
        return gradYear;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }




    public static class Builder{


        private int gradYear;
        private String name;
        private int age;
        private double psp;
        private String universityName;
        private String phoneNumber;

        // Add Setter Methods in Builder and return the class instance
        public Builder gradYear(int gradYear){
            this.gradYear = gradYear;
            return this;
        }

        public Builder name(String name){
            this.name = name;
            return this;
        }

        public Builder age(int age){
            this.age = age;
            return this;
        }
        public Builder psp(double psp){
            this.psp = psp;
            return this;
        }
        public Builder universityName(String universityName){
            this.universityName = universityName;
            return this;
        }
        public Builder phoneNumber(String  phoneNumber){
            this.phoneNumber = phoneNumber;
            return this;
        }

        public void validate(Builder builder) throws Exception{

            if(builder.age <20){
                throw  new Exception("Invalid Age");
            }

            if(builder.gradYear >2024){
                throw  new Exception("Invalid Grad Year");
            }


        }
        public Student build() throws Exception {
           validate(this);
            return new Student(this);
        }

    }

}
