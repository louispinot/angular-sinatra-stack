(function () {
  'use strict';

  angular.module('compass').controller('HomePageCtrl', ['$scope', homePage]);

  var eliasQuote = '"Everyone has an opinion on how to run a business, but no one really knows other than the person in the driving seat. The benchmarking that Compass has developed enables data-driven decision making, helping business leaders evaluate strategy to align the team and ultimately make better decisions on how to allocate resources."';
  var kenQuote = '"When CEOs define goals for their company, they need to think about key strategic initiatives as well as improving their performance in problem areas. Often it\'s hard to figure out if you are doing well in an area or not because you don\'t have a baseline to compare yourself to. Compass solves that problem."';
  var rogerQuote = '"Well-run businesses judge their performance by measuring themselves not only against their own successes but also in comparison with industry competitors. Compass offer a comprehensive set of truly data-driven, next generation benchmarks that provide insights and recommendations to enable better decision-making and superior business performance. All this is done with single click ease."';
  var frodeQuote = '"Overconfidence and complacency are deadly in business. We are excited about Compass because it will give CEOs and investors immediate perspective on how their companies are doing relative to others. For companies that have already embarked on a Lean Transformation, Compass will provide vital benchmarking data. For others, Compass will provide a wakeup call."';

  function homePage($scope) {
    $scope.myInterval = 4000;
    $scope.press = {
      nextWeb: "The Next Web - Compass lets startups check their growth against similar companies",
      wallStreet: "Wall Street Journal - Don't Spend Before You're Ready to Scale",
      economist: "The Economist - The Startup Genome Report turns entrepreneurship into a science",
      gigaom: "Gigaom - New Startup? Dude, There’s a (Genome) Map for That",
      cNet: "Cnet - Uncovering the DNA of successful start-ups"
    };

    $scope.slides = [
      { quote: eliasQuote,
        picture: "Testimonial_EliasBizannes.png",
        name: "Elias Bizanes",
        title: "Founder of StartupBus and StartupHouse."
      },
      { quote: rogerQuote,
        picture: "Testimonial_RogerKrakoff.png",
        name: "Roger Krakoff",
        title: "Managing Partner, Cloud Capital Partners"
      },
      { quote: frodeQuote,
        picture: "testimonial_FrodeLOdegard.png",
        name: "Frode L. Odegard",
        title: "CEO, Lean Systems Institute"
      },
      { quote: kenQuote,
        picture: "testimonial_KenRudin.png",
        name: "Ken Rudin",
        title: "Head of Analytics, Facebook"
      },
    ];

  }

})();