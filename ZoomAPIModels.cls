public class ZoomAPIModels {
	public class createMeet{
        public String topic;
        public Integer type;
        public String start_time;
        public Integer duration;
        public String schedule_for;
        public String timezone;
        public String password;
        public String agenda;
        public Recurrence recurrence;
        public Settings settings;
    }
    
    public class Recurrence{
        public Integer type;
        public Integer repeat_interval;
        public String weekly_days;
        public Integer monthly_day;
        public Integer monthly_week;
        public Integer monthly_week_day;
        public Integer end_times;
        public String end_date_time;
    }
    
    public class Settings{
        public Boolean host_video;
        public Boolean participant_video;
        public Boolean cn_meeting;
        public Boolean in_meeting;
        public Boolean join_before_host;
        public Boolean mute_upon_entry;
        public Boolean watermark;
        public Boolean use_pmi;
        public Integer approval_type;
        public Integer registration_type;
        public String audio;
        public String auto_recording;
        public Boolean enforce_login;
        public String enforce_login_domains;
        public String alternative_hosts;
        public List<String> global_dial_in_countries;
        public Boolean registrants_email_notification;
    }
    
    public class createResponse{
        public String id;
        public String join_url;
        public String topic;
    }
    
    public class addRegistrant{
        public String email;
        public String first_name;
        public String last_name;
        public String country;
        public String phone;
        public String industry;
        public String org;
        public String job_title;
        public String comments;
    }
}