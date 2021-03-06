/**
 * Agile Process Management (OSS)
 *
 * Copyright (C) 2009 - 2010, Ian Zepp <ian.zepp@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@IsTest
private with sharing class WorkstreamUser_InsertSprintUsersTest {
    public static testmethod void testTrigger() {  
        Workstream__c workstream1 = new Workstream__c();
        workstream1.Name = 'Workstream#1';
        insert workstream1; 

        Sprint__c sprint1 = new Sprint__c();
        sprint1.Name = 'Sprint#1';
        sprint1.StartsOn__c = Date.today();
        sprint1.CompletesOn__c = Date.today().addDays(1);
        sprint1.Workstream__c = workstream1.Id;
        insert sprint1;

        system.assertEquals(0, [
            select COUNT()
              from SprintUser__c
             where Sprint__c = :sprint1.Id
        ]);
        
        WorkstreamUser__c workstreamUser1 = new WorkstreamUser__c();
        workstreamUser1.Workstream__c = workstream1.Id;
        workstreamUser1.User__c = UserInfo.getUserId();
        insert workstreamUser1;
        
        system.assertEquals(1, [
            select COUNT()
              from SprintUser__c
             where Sprint__c = :sprint1.Id
        ]);
    }
}