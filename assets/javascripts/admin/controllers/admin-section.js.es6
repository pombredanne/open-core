export default Discourse.AdminSectionController = Ember.ObjectController.extend({
  needs: ['adminToc'],

  isSubSection: Em.computed.notEmpty('model.parent_topic_id'),

  actions: {
    destroy: function() {
      this.get('controllers.adminToc').send('destroy', this.get('model'), this.get('parentController.model.sections'));
    },
  }
});
