// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

Ajax.Responders.register({

  onCreate: function() {
    busyNode = document.createElement('img');
    busyNode.setAttribute('src', '/images/bigrotation2.gif');
    busyNode.setAttribute('id', 'busy');
    document.getElementById('papers').appendChild(busyNode);
    if(Ajax.activeRequestCount > 0)
      Effect.Appear('busy', { duration: 0.5, queue: 'end' });
  },

  onComplete: function() {
    if($('busy') && Ajax.activeRequestCount == 0)
      Effect.Fade('busy', { duration: 0.5, queue: 'end' });
    document.getElementById('papers').removeChild(busyNode);
  }
  
});
