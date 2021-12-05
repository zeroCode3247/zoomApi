public class ZoomCallout {
    @InvocableMethod
    public static List<Output> criarEncontro(List<Input> lstInput){
        System.debug('Entrou criarEncontro');
        String userEmail = UserInfo.getUserEmail();
        List<Output> lstOutput = new List<Output>();
        Output output = new Output();
        Zoom_Web_Service__mdt zoomWS = [SELECT ID, Endpoint__c FROM Zoom_Web_Service__mdt WHERE MasterLabel = 'Create Meeting'];
        List<String> params = new List<String>();
        params.add(userEmail);
        
        String startTime = String.valueOf(lstInput[0].dataEHora).substring(0,10) + 'T' + String.valueOf(lstInput[0].dataEHora).substring(11,19) + 'Z';
        
        ZoomAPIModels.Settings settings = new ZoomAPIModels.Settings();
        settings.participant_video = false;
        settings.join_before_host = true;
        settings.mute_upon_entry = true;
		settings.use_pmi = false;
		settings.approval_type = 0;
		settings.registrants_email_notification = true;

		ZoomAPIModels.createMeet createMeet = new ZoomAPIModels.createMeet();
		createMeet.topic = lstInput[0].topico;
		createMeet.type = 2;
		createMeet.start_time = startTime;
		createMeet.duration = lstInput[0].duracao;
		createMeet.timezone = 'America/Araguaina';
		createMeet.settings = settings;
        createMeet.password = lstInput[0].senha != null ? lstInput[0].senha : null;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(String.format(zoomWS.Endpoint__c, params));
        req.setBody(System.JSON.serialize(createMeet));
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if(res.getStatusCode() == 201 || res.getStatusCode() == 200){
            System.debug('res pass >>>' +res.getBody());
			ZoomAPIModels.createResponse response = (ZoomAPIModels.createResponse) System.JSON.deserialize(res.getBody(), ZoomAPIModels.createResponse.class);
            output.inicio = String.valueOf(lstInput[0].dataEHora).substring(0,10).replace('-', '/') + ' ' + String.valueOf(lstInput[0].dataEHora).substring(11,19);
            output.topico = response.topic;
            output.link = response.join_url;
            output.duracao = lstInput[0].duracao;
            lstOutput = adicionarRegistrante(lstInput, response.id, output);
            
            Encontro__c encontro = new Encontro__c();
        	encontro.Grupo__c = lstInput[0].recordId;
        	encontro.Dura_o__c = lstInput[0].duracao;
        	encontro.Link__c = output.link;
        	encontro.Tema__c = output.topico;
        
        	insert encontro;
        }else{
            System.debug('res fail >>>' +res);
            System.debug('res fail body: ' + res.getBody());
            output.sucesso = false;
        }
        
        return lstOutput;
    }
    
    public static List<Output> adicionarRegistrante(List<Input> lstInput, String meetingId, Output output){
        System.debug('Entrou adicionarRegistrante');
        String userEmail = UserInfo.getUserEmail();
        String recordId = lstInput[0].recordId;
        Integer success = 0;
        List<Output> lstOutput = new List<Output>();
        List<Encontro__c> lstEncontrosToInsert = new List<Encontro__c>();
        
        Zoom_Web_Service__mdt zoomWSRegistrant = [SELECT ID, Endpoint__c FROM Zoom_Web_Service__mdt WHERE MasterLabel = 'Add Registrants'];
        
        List<Rela_o_Integrante_Grupo__c> relacoesGrupo = [SELECT ID, Integrante__r.Name, Integrante__r.Email__c, Integrante__r.Telefone__c FROM Rela_o_Integrante_Grupo__c WHERE Grupo__r.ID =: recordId];
        	
            for(Rela_o_Integrante_Grupo__c relGrupo : relacoesGrupo){
                if(relGrupo.Integrante__r.Email__c == userEmail){
                    continue;
                }
        		
                List<String> paramsRegistrant = new List<String>();
        		paramsRegistrant.add(meetingId);
                
                ZoomAPIModels.addRegistrant addRegistrant = new ZoomAPIModels.addRegistrant();
                addRegistrant.email = relGrupo.Integrante__r.Email__c;
                addRegistrant.first_name = relGrupo.Integrante__r.Name;
                addRegistrant.last_name = '';
                addRegistrant.phone = relGrupo.Integrante__r.Telefone__c;
                addRegistrant.country = 'BR';
                addRegistrant.industry = 'Tech';
                addRegistrant.job_title = 'student';
                addRegistrant.org = 'Universidade São Judas Tadeu';
                addRegistrant.comments = lstInput[0].comentarioDeChamada;
                
                HttpRequest req2 = new HttpRequest();
        		req2.setMethod('POST');
        		req2.setHeader('Content-type', 'application/json');
        		req2.setEndpoint(String.format(zoomWSRegistrant.Endpoint__c, paramsRegistrant));
        		req2.setBody(System.JSON.serialize(addRegistrant));
        		Http http2 = new Http();
        		HttpResponse res2 = http2.send(req2);
                
                if(res2.getStatusCode() == 201){
                    System.debug('Registrante ' + relGrupo.Integrante__r.Name + ' adicionado com sucesso');
                    success++;
                    System.debug('res2: ' + res2.getBody());
                } else{
                    System.debug('Houve um erro ao adicionar o registrante ' + relGrupo.Integrante__r.Name);
                    System.debug('res2: ' + res2.getBody());
                }
    		}
        
        output.sucesso = success == relacoesGrupo.size() ? true : false;
        lstOutput.add(output);
        return lstOutput;
    }
    
    public class Input{
        @InvocableVariable
        public String topico;
        @InvocableVariable
        public Datetime dataEHora;
        @InvocableVariable
        public String senha;
        @InvocableVariable
        public Integer duracao;
        @InvocableVariable
        public String comentarioDeChamada;
        @InvocableVariable
        public String recordId;
    }
    
    public class Output{
        @InvocableVariable
        public String topico;
        @InvocableVariable
        public String link;
        @InvocableVariable
        public Integer duracao;
        @InvocableVariable
        public String inicio;
        @InvocableVariable
        public boolean sucesso;
    }
}