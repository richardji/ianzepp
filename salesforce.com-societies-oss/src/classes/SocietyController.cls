/**
 * Societies Discussion Board (OSS)
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

public with sharing class SocietyController {
    public static final String PARAM_SOCIETY_ID = 'societyId';
    public static final String PARAM_POST_ID = 'postId';
    
    public SocietyController() {
        if (getParam(PARAM_SOCIETY_ID) != null) {
            this.selectedSociety = [
                select Account__r.Name
                     , Account__r.OwnerId
                     , Comments__c
                     , Managers__c
                     , Members__c
                     , Name__c
                     , Type__c
                  from Society__c
                 where Id = :getParam(PARAM_SOCIETY_ID)
            ];
        }
        
        if (getParam(PARAM_POST_ID) != null) {
            this.selectedSocietyPost = [
                select CreatedById
                     , CreatedDate
                     , Depth__c
                     , Disliked__c
                     , FormattedText__c
                     , IsInlineEdit__c
                     , Liked__c
                     , Link__c
                     , Parent__c
                     , Score__c
                     , Society__r.Name__c
                     , Text__c
                     , Type__c
                     , CreatedBy.Name
                     
                     // Also select all of the votes the current user has made
                     , (select Type__c
                          from SocietyVotes__r
                         where CreatedById = :UserInfo.getUserId()) 
                  from SocietyComment__c
                 where Id = :getParam(PARAM_POST_ID)
            ];
        }
    }

    //
    // Convenience helpers
    //

    public String getParam(String name) {
        return ApexPages.currentPage().getParameters().get(name);
    }

    //
    // Selected society
    //

    public Society__c selectedSociety {
        set;
        get;
    }

    //
    // Selected society top-level parent post
    //

    public SocietyComment__c selectedSocietyPost {
        set;
        get;
    }

    //
    // Selected society comment
    //

    public SocietyComment__c selectedSocietyComment {
        set;
        get;
    }

    //
    // Selected society comment (when replying)
    //

    public SocietyComment__c selectedSocietyCommentReply {
        set;
        get;
    }

    //
    // Society methods
    //

    public List<Society__c> getSocietyList() {
        return [
           select Account__r.Name
                , Account__r.OwnerId
                , Comments__c
                , Managers__c
                , Members__c
                , Name__c
                , Type__c
             from Society__c
         order by Members__c desc
        ];
    }

    //
    // Comment list methods
    //
    
    public List<SocietyComment__c> getSocietyPostList() {
        return getSocietyCommentList(new List<String> { 'Post', 'Link' }, 100);
    }
    
    public List<SocietyComment__c> getSocietyCommentList() {
        return getSocietyCommentList(new List<String> { 'Comment', 'Reply' }, 1000);
    }
    
    public List<SocietyComment__c> getSocietyCommentList(List<String> commentType, Integer maxLimit) {
        return [
           select CreatedById
                , CreatedDate
                , Depth__c
                , Disliked__c
                , FormattedText__c
                , IsInlineEdit__c
                , Liked__c
                , Link__c
                , Parent__c
                , Score__c
                , Society__r.Name__c
                , Text__c
                , Type__c
                , CreatedBy.Name
                
                // Also select all of the votes the current user has made
                , (select Type__c
                     from SocietyVotes__r
                    where CreatedById = :UserInfo.getUserId()) 
             from SocietyComment__c
            where Society__c = :selectedSociety.Id
              and Type__c in :commentType
            limit :maxLimit
        ];
    }

    //
    // Returns the total number of comments under a parent post or comment.
    //

    public Integer getSocietyCommentCount() {
        return [
           select COUNT()
             from SocietyComment__c
            where Society__c = :selectedSocietyComment.Society__c
              and ParentHierarchy__c includes (:selectedSocietyComment.Id)
              and Type__c in ('Comment', 'Reply')
        ];
    }

    //
    // Comment voting history / state
    //
    
    public Boolean getIsVotedLiked() {
        return getIsVoted('Liked');
    }
    
    public Boolean getIsVotedDisliked() {
        return getIsVoted('Disliked');
    }
    
    public Boolean getIsVotedSaved() {
        return getIsVoted('Saved');
    }
    
    public Boolean getIsVotedReported() {
        return getIsVoted('Reported');
    }
    
    public Boolean getIsVoted(String voteType) {
        if (selectedSocietyComment == null)
            return false;
        if (selectedSocietyComment.SocietyVotes__r == null)
            return false;
        if (selectedSocietyComment.SocietyVotes__r.size() == 0)
            return false;
        for(SocietyVote__c societyVote : selectedSocietyComment.SocietyVotes__r)
            if (societyVote.Type__c == voteType) return true;
        return false;
    }

    //
    // Special handling to better format comment lines
    //
    
    public List<String> getSocietyCommentParagraphs() {
        if (selectedSocietyComment == null)
            return new List<String>();
        if (selectedSocietyComment.Text__c == null)
            return new List<String>();
    	return selectedSocietyComment.Text__c.split('\n');
    }

    //
    // Update the number of votes
    //
    
    public PageReference insertSocietyVoteLiked() {
        return insertSocietyVote('Liked');
    }

    public PageReference insertSocietyVoteDisliked() {
        return insertSocietyVote('Disliked');
    }
    
    public PageReference insertSocietyVoteReported() {
        return insertSocietyVote('Reported');
    }

    public PageReference insertSocietyVoteSaved() {
        return insertSocietyVote('Saved');
    }
    
    public PageReference insertSocietyVote(String voteType) {
        insert new SocietyVote__c(
            Society__c = getParam('societyId'),
            SocietyComment__c = getParam('societyCommentId'), 
            Type__c = voteType);
        return null;
    }
    
    public PageReference redirectToPostOrLink() {
        SocietyComment__c societyComment = [
           select Type__c
                , Link__c
                , Society__c
             from SocietyComment__c
            where Id = :getParam('societyCommentId')
              and Type__c in ('Post', 'Link')
        ];
        
        if (societyComment.Type__c == 'Post') {
            PageReference pageReference = System.Page.Society;
            pageReference.getParameters().put('societyId', societyComment.Society__c);
            pageReference.getParameters().put('postId', societyComment.Id);
            pageReference.setRedirect(true);
            return pageReference;
        } else if (societyComment.Type__c == 'Link') {
            return new PageReference(societyComment.Link__c);
        } else {
            return null; // error?
        }
    }

    public PageReference redirectToComments() {
        PageReference pageReference = System.Page.Society;
        pageReference.getParameters().put('societyId', getParam('societyId'));
        pageReference.getParameters().put('postId', getParam('postId'));
        pageReference.setRedirect(true);
        return pageReference;
    }

    public PageReference updateReplyStarted() {
        selectedSocietyCommentReply = new SocietyComment__c();
        selectedSocietyCommentReply.Parent__c = getParam('societyCommentId');
        selectedSocietyCommentReply.IsInlineEdit__c = true;
        return null;
    }

    public PageReference updateReplySaved() {
        upsert selectedSocietyCommentReply;

        PageReference pageReference = ApexPages.currentPage();
        pageReference.setAnchor(selectedSocietyCommentReply.Id);
        pageReference.setRedirect(true);
        return pageReference;
    }

    public PageReference updateReplyCanceled() {
        selectedSocietyCommentReply = null;
        return null;
    }

}