function createTopic(topic) {
  var t = Discourse.Topic.create(topic);
  t.category = Discourse.Category.create(topic.category);

  return t;
};

export default Discourse.DiscoveryHomepageRoute = Discourse.Route.extend({
  model: function() {
    return Ember.RSVP.hash({
      active: $.getJSON(Discourse.getURL("top.json")),
      recent: $.getJSON(Discourse.getURL("homepage.json")),
      books: $.getJSON(Discourse.getURL("books"))
    });
  },

  renderTemplate: function(data, model) {
    this.render('homepage', {
      model: {
        active: _(model.active.topic_list.topics).map(createTopic).take(5).value(),
        recent: _.map(model.recent, createTopic),
        books: model.books.table_contents
      },

      controller: 'homepage',
      into: 'discovery',
      outlet: 'homepage'
    });
  },

  activate: function() {
    Ember.$('html').addClass('homepage');
  },

  deactivate: function() {
    Ember.$('html').removeClass('homepage');
  }
});
