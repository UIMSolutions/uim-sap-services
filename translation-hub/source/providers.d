module providers;

import std.array : array;
import std.algorithm : map;
import std.string : format;

interface ITranslationProvider {
    string name() const;
    string translateText(string text, string sourceLanguage, string targetLanguage, string domain = "sap");
}

class SapNmtProvider : ITranslationProvider {
    override string name() const { return "sap-nmt"; }

    override string translateText(string text, string sourceLanguage, string targetLanguage, string domain = "sap") {
        // Placeholder translation strategy emulating SAP NMT tuned for SAP terminology.
        return format("[SAP-NMT %s->%s/%s] %s", sourceLanguage, targetLanguage, domain, text);
    }
}

class LlmProvider : ITranslationProvider {
    override string name() const { return "llm"; }

    override string translateText(string text, string sourceLanguage, string targetLanguage, string domain = "generic") {
        // Placeholder translation strategy emulating LLM-style adaptation for non-SAP content.
        return format("[LLM %s->%s/%s] %s", sourceLanguage, targetLanguage, domain, text);
    }
}

class MltrProvider : ITranslationProvider {
    private string _providerName;

    this(string providerName) {
        _providerName = providerName;
    }

    override string name() const { return _providerName; }

    override string translateText(string text, string sourceLanguage, string targetLanguage, string domain = "custom") {
        // Placeholder reusable translation memory behavior.
        return format("[%s %s->%s/%s] %s", _providerName, sourceLanguage, targetLanguage, domain, text);
    }
}

class ProviderRegistry {
    private ITranslationProvider[string] _providers;

    this() {
        register(new SapNmtProvider());
        register(new LlmProvider());
        register(new MltrProvider("mltr"));
        register(new MltrProvider("company-mltr"));
    }

    void register(ITranslationProvider provider) {
        _providers[provider.name] = provider;
    }

    ITranslationProvider get(string providerName) {
        if (providerName in _providers) {
            return _providers[providerName];
        }
        return _providers["sap-nmt"];
    }

    string[] names() const {
        return _providers.keys.map!(k => k.idup).array;
    }
}
