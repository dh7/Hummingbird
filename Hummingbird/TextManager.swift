import Cocoa

class TextManager {
    static func requestAccessibilityPermissions() -> Bool {
        // First check if we already have permissions
        if AXIsProcessTrusted() {
            print("Already has accessibility permissions")
            return true
        }
        
        // If not, request them
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        
        // Check again after the prompt
        let trusted = AXIsProcessTrusted()
        print("Accessibility permissions status: \(trusted)")
        return trusted
    }
    
    static func getSelectedText() -> String? {
        print("Attempting to get selected text...")
        
        // First check/request permissions
        guard requestAccessibilityPermissions() else {
            print("No accessibility permissions")
            return nil
        }
        
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        
        let focusedStatus = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        print("Focus status: \(focusedStatus.rawValue)")
        
        guard focusedStatus == .success,
              let element = focusedElement else {
            print("Failed to get focused element")
            return nil
        }
        print("Got focused element")
        
        // Try different text attributes
        let textAttributes = [
            kAXSelectedTextAttribute,
            kAXValueAttribute,
            kAXStringForRangeParameterizedAttribute
        ]
        
        for attribute in textAttributes {
            var selectedText: AnyObject?
            let selectedStatus = AXUIElementCopyAttributeValue(element as! AXUIElement, attribute as CFString, &selectedText)
            print("Selected text status for \(attribute): \(selectedStatus.rawValue)")
            
            if selectedStatus == .success,
               let text = selectedText as? String {
                print("Successfully got text using \(attribute): \(text)")
                return text
            }
        }
        
        // If we couldn't get the text directly, try getting the range and then the text
        var selectedRange: AnyObject?
        let rangeStatus = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRange)
        
        if rangeStatus == .success,
           let range = selectedRange {
            var selectedText: AnyObject?
            let parameterizedStatus = AXUIElementCopyParameterizedAttributeValue(element as! AXUIElement, 
                                                                               kAXStringForRangeParameterizedAttribute as CFString,
                                                                               range as CFTypeRef,
                                                                               &selectedText)
            
            if parameterizedStatus == .success,
               let text = selectedText as? String {
                print("Successfully got text using range: \(text)")
                return text
            }
        }
        
        print("Failed to get selected text")
        return nil
    }

    static func setSelectedText(_ newText: String) {
        print("Attempting to set text: \(newText)")
        
        // First check/request permissions
        guard requestAccessibilityPermissions() else {
            print("No accessibility permissions")
            return
        }
        
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        
        let focusedStatus = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        print("Focus status for setting: \(focusedStatus.rawValue)")
        
        guard focusedStatus == .success,
              let element = focusedElement else {
            print("Failed to get focused element for setting text")
            return
        }
        print("Got focused element for setting text")
        
        // Try different methods to set the text
        let setStatus1 = AXUIElementSetAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, newText as CFTypeRef)
        if setStatus1 == .success {
            print("Successfully set text using kAXSelectedTextAttribute")
            return
        }
        
        let setStatus2 = AXUIElementSetAttributeValue(element as! AXUIElement, kAXValueAttribute as CFString, newText as CFTypeRef)
        if setStatus2 == .success {
            print("Successfully set text using kAXValueAttribute")
            return
        }
        
        print("Failed to set text. Status codes: \(setStatus1.rawValue), \(setStatus2.rawValue)")
    }
}
