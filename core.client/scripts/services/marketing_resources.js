(function() {
  'use strict';

  angular.module('compass').factory('marketingResourcesSvc',[marketingResourcesSvc]);

  function marketingResourcesSvc () {
    var service = {
      displayName: displayName,
      tooltip: tooltip
    };

    function displayName(metricName){
      var dictionary = {
        "ONLINE_ADS": "Online Ads",
        "ADWORDS": "Adwords/PPC",
        "SEO": "SEO",
        "SOCIAL": "Social",
        "AFFILIATE_AND_LEAD_GENERATION": "Affiliate/Lead Generation",
        "CONTENT_MARKETING": "Content Marketing",
        "MOBILE": "Mobile",
        "EMAIL": "Email",
        "DISPLAY_ADS": "Display Ads",
        "OFFLINE_ADS": "Offline Ads",
        "DIRECT_SALES": "Direct Sales/Bizdev",
        "PR": "PR",
        "VIRAL_AND_REFERRAL": "Virar/Referral",
        "APPSTORES_AND_MARKETPLACES": "App Stores/Marketplaces"
      };
      if (dictionary[metricName]){
        return dictionary[metricName];
      } else {
        return metricName;
      }

    }

    function tooltip(metricName){
      var tooltips = {
        "ADWORDS": "Include spendings on pay-per-click ads, agency fees andthe  salaries of PPC managers.",
        "SEO": "Include agency fees, SEO managers' salary and IT resources for SEO",
        "SOCIAL": "Include spending on ads on social networks and the salaries of social media managers and content producers.",
        "AFFILIATE_AND_LEAD_GENERATION": "Include acquisition costs for affiliates, the salaries of affiliate managers and revenue given out to affiliates and lead generators.",
        "CONTENT_MARKETING": "Include the salaries of content managers, authors and other employees involved in content creation, publishing and promotion.",
        "MOBILE": "Include spending on mobile ads, agency fees and the salaries of mobile ads managers.",
        "EMAIL": "Include the salaries of email managers and other employees involved in email creation and distribution, plus fees for email management tools.",
        "DISPLAY_ADS": "Include spending on display (banner) ads, agency fees and the salaries of relevant managers.",
        "OFFLINE_ADS": "Include spending on offline ads (TV, radio, billboards, direct mail, etc), agency fees and the salaries of relevant managers.",
        "DIRECT_SALES": "Include the salaries and bonuses of sales reps and business development managers.",
        "PR": "Include the salaries of PR managers and all PR costs.",
        "VIRAL_AND_REFERRAL": "Include revenue given as discounts for referrals and development costs for referral programs.",
        "APPSTORES_AND_MARKETPLACES": "Include marketplace placement and promotion costs and other costs related to marketplaces.",
        "add_category": "Only add channels that aren't related to existing categories"
      };
      return tooltips[metricName];

    }

    return service;
  }

})();