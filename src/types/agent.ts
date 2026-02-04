export interface Agent {
  name: string;
  description?: string;
  systemPrompt?: string;
  skills: {
    enabled: string[];
  };
  tools: {
    enabled: string[];
    disabled: string[];
  };
  memory?: {
    scope?: string[];
    deny?: string[];
  };
}

export interface Tool {
  name: string;
  description: string;
  category: string;
  riskLevel: 'low' | 'medium' | 'high' | 'critical';
}

export interface Skill {
  name: string;
  description: string;
  version: string;
  author?: string;
}
