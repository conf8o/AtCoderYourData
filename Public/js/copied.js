$(function () {
    const clipboard = new ClipboardJS('.clipboard');
    clipboard.on('success', (e) => {
        
        const $copySuccessText = $(`span[name="${e.trigger.name}"]`);
        $copySuccessText.text('Copied!');
        const $copyButton = $(`button[name="${e.trigger.name}"]`);
        $copyButton.hover(() => {
            $copySuccessText.text('');
            $copyButton.off();
        });
        
        e.clearSelection();
    });
});
